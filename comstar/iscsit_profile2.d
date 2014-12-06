#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

iscsi:idm::login-command,
iscsi:idm::logout-command,
iscsi:iscsit::scsi-command,
iscsi:iscsit::xfer-start,
iscsi:iscsit::xfer-done
{
	@[probefunc] = count();
}

fbt:stmf:stmf_dlun0_new_task:entry
/* /((scsi_task_t *) arg0)->task_mgmt_function/ */
{
	this->task = (scsi_task_t *) arg0;
	@dlun0_tm[this->task->task_mgmt_function] = count();
	/* printf("****stmf_dlun0_new_task(tm_task) called at: %d (msec)*****", timestamp/1000000); */
}


fbt:stmf:stmf_post_task:entry
/((scsi_task_t *) arg0)->task_mgmt_function/
{
	/* stack(); */
	this->task = (scsi_task_t *) arg0;
	@post_tm[this->task->task_mgmt_function] = count();
	printf("****stmf_post_task(tm_task) called at: %d (msec)*****", timestamp/1000000);
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

	printf("stmf_do_ilu_timeouts for %s at: %d (usec)", stringof(this->lu->lu_alias), timestamp/1000);
	@task[probefunc] = count();
}

fbt:stmf:stmf_handle_lun_reset:entry
{
	stack();
	self->ts = timestamp;
	printf("*******stmf_handle_lun_reset called at: %d*******", timestamp/1000000);
	@task[probefunc] = count();
}

fbt:stmf:stmf_handle_lun_reset:return
{
	printf("Lun reset rval: %d  Latency: %d", arg0, (timestamp - self->ts)/1000);
	self->ts = 0;
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

	printf("\nstmf_dlun0_new_task(tm)");
        printa(@dlun0_tm);
}
