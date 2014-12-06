#!/usr/sbin/dtrace -s

sdt:stmf:stmf_abort:scsi-task-abort
/* /((scsi_task_t *)arg0)->task_mgmt_function/ */
{
	this->task = (scsi_task_t *)arg0;
	this->dbuf = (stmf_data_buf_t *)arg1;

	printf("\t task_mgmt_function: %d\n", this->task->task_mgmt_function);
	stack();
}

fbt:stmf:stmf_handle_lun_reset:entry
{
	self->lun = timestamp;
	stack();
}

fbt:stmf:stmf_handle_lun_reset:return
/self->lun/
{
	@lun = quantize(timestamp - self->lun);
	self->lun = 0;
}

fbt:stmf:stmf_handle_target_reset:entry
{
	self->target = timestamp;
	stack();
}

fbt:stmf:stmf_handle_target_reset:return
/self->target/
{
	@target = quantize(timestamp - self->target);
	self->target = 0;
}

fbt:stmf:stmf_do_ilu_timeouts:entry
{
        stack();
}

profile:::tick-10s
{
        printf("\n\t\tstmf_handle_target_reset latency (usec)\n");
        printa(@target);
        printf("\n\t\tstmf_handle_lun_reset latency (usec)\n");
        printa(@target);
}
