#!/usr/sbin/dtrace -qs

/*
 *  args[] = 
 *  fct_cmd_t, cmd,
 *  fct_i_local_port_t, iport,
 *  scsi_task_t, task,
 *  fct_i_remote_port_t, irp);
 */
fc:::scsi-command
/((scsi_task_t *) arg2)->task_cdb[0] != 0x0/    /* for some strange reason, OSX sends 0x0 cmd to dlun0 */
{
	this->cmd = arg0;
	this->ilport = (fct_i_local_port_t *) arg1;
	this->task = (scsi_task_t *) arg2;
	this->irport = (fct_i_remote_port_t *) arg3;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

        @cmds[stringof(this->ilport->iport_alias), stringof(this->rport->rp_pwwn_str),
	     this->task->task_cdb[0], this->task->task_cdb[1]] = count();
}

/*
 *  args[] = 
 *      fct_cmd_t, cmd,
 *      fct_i_local_port_t, (fct_i_local_port_t *)cmd->cmd_port->port_fct_private,
 *      scsi_task_t, task,
 *      fct_i_remote_port_t, (fct_i_remote_port_t *)cmd->cmd_rp->rp_fct_private);
 */
fc:::scsi-response
/((scsi_task_t *) arg2)->task_cdb[0] != 0x0/    /* for some strange reason, OSX sends 0x0 cmd to dlun0 */
{
	this->cmd = arg0;
	this->ilport = (fct_i_local_port_t *) arg1;
	this->task = (scsi_task_t *) arg2;
	this->irport = (fct_i_remote_port_t *) arg3;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

        @resp[stringof(this->ilport->iport_alias), stringof(this->rport->rp_pwwn_str),
	    this->task->task_cdb[0], this->task->task_scsi_status] = count();
}

profile:::tick-1s
{
	printf("\ncmds\n"); printa("%s:%s 0x%x 0x%x	%@20d\n", @cmds); trunc(@cmds, 0);
	printf("resp\n"); printa("%s:%s 0x%x 0x%x	%@20d\n", @resp); trunc(@resp, 0);
}
