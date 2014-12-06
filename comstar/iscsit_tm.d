#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

iscsi:iscsit::scsi-command
{
	@[probefunc] = count();
}

fbt:stmf:stmf_post_task:entry
/((scsi_task_t *) arg0)->task_mgmt_function/
{
	/* stack(); */
	this->task = (scsi_task_t *) arg0;
	@post_tm[this->task->task_mgmt_function] = count();

	@checkpoint[probefunc, timestamp/1000000000] = count();
}

fbt:stmf:stmf_lun_reset_poll:entry
{
	@lun_reset_stack[stack()] = count();

	this->task = (scsi_task_t *) arg1;
	@lun_reset_poll[this->task->task_mgmt_function] = count();
}

fbt:stmf_sbd:sbd_abort:entry
{
	@sbd_abort_stack[stack()] = count();
	this->lu =  (stmf_lu_t *) arg0;
	@sbd_abort[stringof(this->lu->lu_alias), arg1] = count();

	@checkpoint[probefunc, timestamp/1000000000] = count();
}

fbt:stmf:stmf_queue_task_for_abort:entry
/((scsi_task_t *) arg0)->task_mgmt_function/
{
	printf("stmf_queue_task_for_abort(%d) called at: %d (usec)",
	    ((scsi_task_t *) arg0)->task_mgmt_function, timestamp/1000);
	@task[probefunc] = count();
}

fbt:stmf:stmf_do_ilu_timeouts:entry
{
	this->ilu = (stmf_i_lu_t *)arg0;
	this->lu =  (stmf_lu_t *) this->ilu->ilu_lu;
	@task[probefunc] = count();
}

fbt:stmf:stmf_handle_lun_reset:entry
{
	stack();
	printf("*******stmf_handle_lun_reset called at: %d*******", timestamp/1000000);
	@task[probefunc] = count();
}

profile:::tick-10s
{
	printf("\n==============================================\n");
	printf("\n\nCommands and transfers");
        printa(@);
	trunc(@, 0);

	printf("\nTask management related functions");
        printa(@task);

	printf("\nstmf_post_task(tm)");
        printa(@post_tm);

	printf("\nsbd_abort");
        printa(@sbd_abort);

	printf("\ncheckpoints(secs)");
        printa(@checkpoint);

	printf("\nsbd_abort stack");
        printa(@sbd_abort_stack);

	printf("\nlun_reset_poll");
        printa(@lun_reset_poll);

	printf("\nlun_reset_poll stack");
        printa(@lun_reset_stack);
}
