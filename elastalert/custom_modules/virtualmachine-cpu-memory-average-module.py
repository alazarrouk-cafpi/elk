from datetime import datetime
from elastalert.ruletypes import RuleType
from elasticsearch import Elasticsearch
from elastalert.alerters.email import EmailAlerter
from elastalert.alerters.httppost2 import HTTPPost2Alerter
import yaml
import json
class VirtualmachineCpuMemoryAverageRule(RuleType):
    def __init__(self, *args):
        super(VirtualmachineCpuMemoryAverageRule, self).__init__(*args)
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
        es_query_cpu = {
            "size": 0,
            "query": {
                "range": {
                "@timestamp": {
                    "gte": "now-10m",
                    "lte": "now"
                }
                }
            },
            "aggs": {
                "virtualmachines": {
                    "terms": {
                        "field": "agent.name",
                        "size": 10 
                    },
                    "aggs": {
                        "cpu_avg": {
                        "filter": {
                            "term": {
                            "event.dataset": "system.cpu"
                            }
                        },
                        "aggs": {
                            "average_cpu": {
                            "avg": {
                                "field": "system.cpu.total.norm.pct"
                            }
                            }
                        }
                        },
                        "subscription_id": {
                            "terms": {
                                "field": "cloud.account.id",
                                "size": 1
                            }
                        },
                        "username": {
                            "terms": {
                                "field": "user.name",
                                "size": 1
                            }
                        }
                    }
                }
            }
        }
        es_query_memory = {
            "size": 0,
            "query": {
                "range": {
                   "@timestamp": {
                      "gte": "now-10m",
                      "lte": "now"
                    }
                }
            },
            "aggs": {
                "virtualmachines": {
                    "terms": {
                        "field": "agent.name",
                        "size": 10 
                    },
                    "aggs": {
                        "memory_avg": {
                        "filter": {
                            "term": {
                            "event.dataset": "system.memory"
                            }
                        },
                        "aggs": {
                            "average_memory": {
                            "avg": {
                                "field": "system.memory.actual.used.pct"
                            }
                            }
                        }
                        },
                        "subscription_id": {
                            "terms": {
                                "field": "cloud.account.id",
                                "size": 1
                            }
                        },
                        "username": {
                            "terms": {
                                "field": "user.name",
                                "size": 1
                            }
                        }
                    }
                }
            }
        }

        # Execute the query
        result_cpu = es.search(index=".ds-metrics-system.cpu-default-*", body=es_query_cpu)
        result_memory= es.search(index=".ds-metrics-system.memory-default-*", body=es_query_memory)
        cpu_threshold=8 
        memory_threshold=60
        print(result_cpu)
        # Process the results
        for bucket in result_cpu['aggregations']['virtualmachines']['buckets']:
            subscriptionId=''
            username=''
            virtualMachineName = bucket['key']
            averageCpu = round((bucket['cpu_avg']['average_cpu']['value'])*100, 2)
            averageMemory = 0
            for bucket_mem in result_memory['aggregations']['virtualmachines']['buckets']:
                if bucket_mem['key'] == virtualMachineName :
                    averageMemory = round((bucket_mem['memory_avg']['average_memory']['value'])*100, 2)
                    break
            
            for bk in bucket['subscription_id']['buckets']: 
                subscriptionId=bk['key']
            for bkus in bucket['username']['buckets']: 
                username=bkus['key']
            if username != 'root': 
            # Example: Add a match if the count exceeds a certain threshold 
                if averageCpu > cpu_threshold and averageMemory > memory_threshold: 
                    match = {
                        "alert_type": 'cpu,memory',
                        "virtualmachineName": virtualMachineName,
                        "subscriptionId": subscriptionId,
                        "average_cpu": averageCpu,
                        "average_memory":averageMemory,
                        "date" : current_time
                    }
                else :
                    if averageCpu > cpu_threshold:
                        match = {
                            "alert_type": 'cpu',
                            "virtualmachineName": virtualMachineName,
                            "subscriptionId": subscriptionId,
                            "average_cpu": averageCpu,
                            "date" : current_time
                        }
                    if averageMemory > memory_threshold:
                        match = {
                            "alert_type": 'memory',
                            "virtualmachineName": virtualMachineName,
                            "subscriptionId": subscriptionId,
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
        return "Service %s had %s hits in the last 30 minutes" % (match['service_name'], match['count'])
    def garbage_collect(self, timestamp):
        pass