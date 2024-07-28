CREATE TABLE [dbo].[azure_virtualmachine_sku] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [name]         VARCHAR (255) NULL,
    [vcpu]         VARCHAR (255) NULL,
    [memory]       VARCHAR (255) NULL,
    [disks]        VARCHAR (255) NULL,
    [iops]         INT           NULL,
    [localstorage] VARCHAR (255) NULL,
);
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_B1s', '1', '1', '2',320,'4');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_B1ms', '1', '2', '2',640,'4');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_B2s', '2', '4', '4',1280,'8');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_B2ms', '2', '8', '4',1920,'16');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_B4ms', '4', '16', '8',2880,'32');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_D2s_v3', '2', '8', '4',3200,'16');
INSERT INTO azure_virtualmachine_sku (name, vcpu, memory,disks ,iops,localstorage)  VALUES ('Standard_D2as_v4', '4', '16', '8',6400,'32');

CREATE TABLE [dbo].[azure_appserviceplan_sku] (
    [id]      INT           IDENTITY (1, 1) NOT NULL,
    [name]    VARCHAR (255) NULL,
    [vcpu]    VARCHAR (255) NULL,
    [memory]  VARCHAR (255) NULL,
    [storage] VARCHAR (255) NULL,
    [scale]   VARCHAR (255) NULL,
);
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('Free F1', 'N/A', '1', '1', 'N/A');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('Basic B1', '1', '1.75', '10', '3');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('Basic B2', '2', '3.5', '10', '3');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('Basic B3', '4', '7', '10', '3');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('Premium0V3 P0v3', '1', '4', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P1v3', '2', '8', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P1mv3', '2', '16', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P2v3', '4', '16', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P2mv3', '4', '32', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P3v3', '8', '32', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P3mv3', '8', '64', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P4vm3', '16', '128', '250', '30');
INSERT INTO azure_appserviceplan_sku (name, vcpu, memory, storage, scale) VALUES ('PremiumV3 P5mv3', '32', '256', '250', '30');



CREATE TABLE [dbo].[appserviceplan_optimization_sku] (
    [id]                 INT           IDENTITY (1, 1) NOT NULL,
    [old_name]           VARCHAR (255) NULL,
    [old_vcpu]           VARCHAR (255) NULL,
    [old_memory]         VARCHAR (255) NULL,
    [old_storage]        VARCHAR (255) NULL,
    [old_instance_count] VARCHAR (255) NULL,
    [new_name]           VARCHAR (255) NULL,
    [new_vcpu]           VARCHAR (255) NULL,
    [new_memory]         VARCHAR (255) NULL,
    [new_storage]        VARCHAR (255) NULL,
    [new_instance_count] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);
CREATE TABLE [dbo].[virtualmachine_optimization_sku] (
    [id]                 INT           IDENTITY (1, 1) NOT NULL,
    [old_name]           VARCHAR (255) NULL,
    [old_vcpu]           VARCHAR (255) NULL,
    [old_memory]         VARCHAR (255) NULL,
    [old_disks]          VARCHAR (255) NULL,
    [old_iops]           INT           NULL,
    [old_storage]        VARCHAR (255) NULL,
    [new_name]           VARCHAR (255) NULL,
    [new_vcpu]           VARCHAR (255) NULL,
    [new_memory]         VARCHAR (255) NULL,
    [new_disks]          VARCHAR (255) NULL,
    [new_iops]           VARCHAR (255) NULL,
    [new_storage]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);
CREATE TABLE [dbo].[optimization] (
    [id]                                 INT           IDENTITY (1, 1) NOT NULL,
    [type]                               VARCHAR (255) NULL,
    [action]                             VARCHAR (255) NULL,
    [date]                               DATETIME      NULL,
    [appserviceplan_optimization_sku_id] INT           NULL,
    [storageaccount_id]                  TEXT          NULL,
    [virtualmachine_optimization_sku_id] INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    FOREIGN KEY ([appserviceplan_optimization_sku_id]) REFERENCES [dbo].[appserviceplan_optimization_sku] ([id]),
    FOREIGN KEY ([virtualmachine_optimization_sku_id]) REFERENCES [dbo].[virtualmachine_optimization_sku] ([id])
);
CREATE TABLE [dbo].[alert] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [type]                VARCHAR (255) NULL,
    [azure_resource_type] VARCHAR (255) NULL,
    [date]                DATETIME      NULL,
    [value]               VARCHAR (255) NULL,
    [azure_resource_name] VARCHAR (255) NULL,
    [state]               VARCHAR (50)  NOT NULL,
    [appserviceplan_id]   VARCHAR (MAX) NULL,
    [virtualmachine_id]   VARCHAR (MAX) NULL,
    [optimization_id]     INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    FOREIGN KEY ([optimization_id]) REFERENCES [dbo].[optimization] ([id])
);