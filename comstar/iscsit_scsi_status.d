#!/usr/sbin/dtrace -s


fbt:iscsit:iscsit_send_scsi_status:entry
{
	this->task = (scsi_task_t *)arg0;
	this->itask = (iscsit_task_t *) this->task->task_port_private;

	@task[this->task->task_completion_status, this->task->task_scsi_status,
	    this->itask->it_stmf_abort] = count();
}

fbt:iscsit:iscsit_abort:entry
{
	@funcs[probefunc] = count();
}

fbt:stmf:stmf_do_task_abort:entry
{
	@funcs[probefunc] = count();
}

fbt:stmf:stmf_queue_task_for_abort:entry
{
	@funcs[probefunc] = count();
}

/* fbt:fbt:iscsit"iscsit_send_scsi_status: */

profile:::tick-10s
{
	printa(@task);
	clear(@task);

	printf("Functions\n");
	printa(@funcs);
}
