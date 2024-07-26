from datetime import datetime
from elastalert.ruletypes import RuleType
from elasticsearch import Elasticsearch
from elastalert.alerters.email import EmailAlerter
from elastalert.alerters.httppost2 import HTTPPost2Alerter
import yaml
import json
class AppserviceMemoryAverageRule(RuleType):
    def __init__(self, *args):
        super(AppserviceMemoryAverageRule, self).__init__(*args)
        # Load configuration
        with open('config/config.yaml', 'r') as config_file:
            self.config = yaml.safe_load(config_file)

    def add_data(self, data):
        current_time = datetime.now().isoformat()
        # Create Elasticsearch client
        es = Elasticsearch(
            hosts=[{'host': self.rules['es_host'], 'port': self.rules['es_port']}],
            http_auth=(self.rules['es_username'], self.rules['es_password']),
            use_ssl=self.config['use_ssl'],
            verify_certs=self.config['verify_certs'],
            ca_certs=self.config['ca_certs'],
            client_cert=self.config['client_cert'],
            client_key=self.config['client_key'],
            timeout=60  # Timeout set to 60 seconds
        )
        # Define the Elasticsearch query
        es_query = {
            "size": 0,
            "query": {
                "bool": {
                    "must": [
                        {"query_string": {"query": "data.metricName: \"MemoryPercentage\""}},
                        {"range": {"data.time": {"gte": "now-31m", "lte": "now"}}}
                    ]
                }
            },
            "aggs": {
                "appservice_plans": {
                    "terms": {
                      "field": "data.appservicePlan.keyword"
                    },
                    "aggs": {
                      "average_memory": {
                        "avg": {
                          "field": "data.total"
                        }
                      },
                      "resource_id": {
                        "terms": {
                            "field": "data.resourceId.keyword",
                            "size": 1
                        }
                      }
                    }
                }
            }
        }

        # Execute the query
        result = es.search(index="appservices-metrics-*", body=es_query)

        # Process the results
        for bucket in result['aggregations']['appservice_plans']['buckets']:
            appservicePlanId = ''
            appservicePlan = bucket['key']
            for bk in bucket['resource_id']['buckets']: 
              appservicePlanId=bk['key']
            averageMemory = bucket['average_memory']['value']
            # Example: Add a match if the count exceeds a certain threshold
            if averageMemory > 60:
                match = {
                    "appservice_plan": appservicePlan,
                    "appserviceplan_id": appservicePlanId,
                    "average_memory": averageMemory,
                    "date" : current_time
                }
                # Send email alert for the match
                # self.email_alerter.alert([match])
                self.send_http_post(match)

    def send_http_post(self, match):
        # Instantiate HTTPPost2Alerter and send alert
        alerter = HTTPPost2Alerter(self.rules)
        alerter.alert([match])

    def get_match_str(self, match):
        return "Service %s had %s hits in the last 30 minutes" % (match['appservice_plan'], match['count'])
    def garbage_collect(self, timestamp):
        pass