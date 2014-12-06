#!/usr/sbin/dtrace -qs

fbt::stmf_post_task:entry
{
	this->task = (scsi_task_t *) arg0;
	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private; 

	/*
	this->lu_lp = (stmf_lu_provider_t *) this->task_lu->lu_lp; 
	@tasks[stringof(this->lu_lp->lp_name), this->lu_lp->lp_instance,
	    this->task->task_cdb[0], this->task->task_flags] = count();
	*/

	@tasks[stringof(this->sl->sl_name), this->sl->sl_access_state,
	    this->task->task_cdb[0], this->task->task_flags] = count();

	@total[stringof(this->sl->sl_name), this->sl->sl_access_state,
	    this->task->task_cdb[0], this->task->task_flags] = count();
}

profile:::tick-1s
{
	printf("\n=============\n");
	printa("%s (%d): 0x%x  0x%x \t%@20d\n", @tasks); trunc(@tasks, 0);
}

END
{
	printa("%s (%d): 0x%x  0x%x \t%@20d\n", @total);
}
