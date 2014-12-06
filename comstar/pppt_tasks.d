#!/usr/sbin/dtrace -qs

fbt:pppt:pppt_msg_scsi_cmd:entry
{
	self->note = 1;
}

fbt:stmf:stmf_post_task:entry
/self->note/
{
        this->task = (scsi_task_t *) arg0;
        this->task_lu = (stmf_lu_t *) this->task->task_lu; 
        this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private; 

        @tasks[stringof(this->sl->sl_name), this->task->task_cdb[0],
	    this->task->task_additional_flags] = count();
        @total[stringof(this->sl->sl_name), this->task->task_cdb[0],
	    this->task->task_additional_flags] = count();
}

fbt:pppt:pppt_msg_scsi_cmd:return
/self->note/
{
	self->note = 0;
}

profile:::tick-2s
{
        printf("\n=============\n");
        printa("%s: 0x%x (0x%x) \t%@20d\n", @tasks); trunc(@tasks, 0);
}

END
{
        printf("\nTotal\n");
        printa("%s: 0x%x (0x%x) \t%@20d\n", @total);
}
