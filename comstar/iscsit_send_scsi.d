#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

sdt:iscsit:iscsit_send_task_mgmt_resp:iscsi-scsi-tm-response
{
	@mgmt[arg1] = count();
}

/*
sdt:iscsit:iscsit_send_scsi_status:iscsi-scsi-response
{
	@scsi[arg1, arg2] = count();
}*/

profile:::tick-10s
{
	/*
	printf("\nsend_scsi_status\n");
        printa(@scsi);
	*/

	printf("send_mgmt_resp\n");
	printa(@mgmt);

	trunc(@mgmt, 0);
}

