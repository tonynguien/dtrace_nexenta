#!/usr/sbin/dtrace -qs

/*
 * read task completed
 */
fbt:stmf:stmf_send_status_done:entry
{
        this->task = (scsi_task_t *) arg0;
        this->lu = (stmf_lu_t *) this->task->task_lu;
        this->itask = (stmf_i_scsi_task_t *) this->task->task_stmf_private;
        this->lport = this->task->task_lport;

	@[this->task->task_cdb[0], this->itask->itask_flags] = count();
}

profile:::tick-1sec
{
	printa("0x%-5x 0x%-5x %@10d\n", @); trunc(@);
}
