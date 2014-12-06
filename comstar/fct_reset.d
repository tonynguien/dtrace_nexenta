#!/usr/sbin/dtrace -s

/*
 * Trace task abort stack and aborted commands
 */

fbt:stmf:stmf_queue_task_for_abort:entry
{
	this->task = (scsi_task_t *) arg0;
	printf("time:%Y  probefunc:%s  task:%x\n", walltimestamp, probefunc, this->task->task_cdb[0]);
	stack();
}

/*
 * Trace LPORT/LU offline and online operations
 *
 * stmf_task_lport_aborted(scsi_task_t *task, stmf_status_t s, uint32_t iof) -> stmf_abort_task_offline(task, 0, info);
 * stmf_do_task_abort(scsi_task_t *task) -> stmf_abort_task_offline(itask->itask_task, 0, info);
 *   -> stmf_abort_task_offline() -> stmf_ctl(STMF_CMD_LPORT_OFFLINE);
 */

fbt:stmf:stmf_do_task_abort:entry
{	
	self->tr = 1;
	this->task = (scsi_task_t *) arg0;
}

fbt:stmf:stmf_abort_task_offline:entry
/self->tr/
{

}

fbt:stmf:stmf_ctl:entry
/self->tr/
{
	printf("time:%Y  %s  %d\n", walltimestamp, probefunc, arg0);
}

fbt:stmf:stmf_svc_queue:entry
/self->tr/
{
	printf("time:%Y  %s  %d\n", walltimestamp, probefunc, arg0);
	stack();
}

fbt:stmf:stmf_do_task_abort:return
/self->tr/ { self->tr = 0; }

/*
 * Finally, stack of fct_ctl offline/online for confirmation
 */
fbt::fct_ctl:entry
{

}
