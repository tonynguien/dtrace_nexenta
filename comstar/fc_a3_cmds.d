#!/usr/sbin/dtrace -qs

/*
 *  args[] = 
 *  fct_cmd_t, cmd,
 *  fct_i_local_port_t, iport,
 *  scsi_task_t, task,
 *  fct_i_remote_port_t, irp);
fbt::fct_send_scsi_status:entry
{
	this->task = (scsi_task_t *) arg0;

        @resp[this->task->task_cdb[0], this->task->task_cdb[1],
	    this->task->task_scsi_status] = count();
}
*/

/*
 *  stmf_scsilib_send_status(task, STATUS_CHECK, STMF_SAA_INVALID_FIELD_IN_CDB);
 */
fbt:stmf:stmf_scsilib_send_status:entry
{
	this->task = (scsi_task_t *) arg0;
        /* @status[this->task->task_cdb[0], this->task->task_cdb[1], arg1, arg2] = count();*/

	printf("0x0%x0%x:  0x0%x 0x0%x\n", this->task->task_cdb[0],
	    this->task->task_cdb[1], arg1, arg2); 
}

/*
profile:::tick-1s
{
	printf("\nstatus\n");
	printa("0x0%x0%x:  0x0%x   %@20d\n", @resp); trunc(@resp, 0);
}
*/
