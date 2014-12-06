#!/usr/sbin/dtrace -Fs

/* command timeout */ 
fbt:mpt_sas:mptsas_cmd_timeout:entry
{
	self->tr = 1;
	printf("%s timestamp:%d target:%d\n", probefunc, timestamp, (uint16_t) arg1);
}

fbt:mpt_sas:mptsas_ioc_task_management:entry
/self->tr/ { printf("%s timestamp:%d\n", probefunc, timestamp); }

fbt:mpt_sas:mptsas_cmd_timeout:return
/self->tr/ { self->tr = 0; }


/* config target */ 
fbt:mpt_sas:mptsas_config_target:entry
{
	self->tr = 1;
	printf("%s timestamp:%d\n", probefunc, timestamp);
}

fbt:sd:sd_send_scsi_START_STOP_UNIT:entry
/self->tr/ { printf("%s timestamp:%d\n", probefunc, timestamp); } 

fbt:scsi:scsi_uscsi_handle_cmd:entry
/self->tr/ { printf("%s timestamp:%d\n", probefunc, timestamp); } 

fbt:genunix:biowait:entry
/self->tr/ { printf("%s timestamp:%d\n", probefunc, timestamp); } 

fbt:mpt_sas:mptsas_config_target:return
/self->tr/ { self->tr = 0; }
