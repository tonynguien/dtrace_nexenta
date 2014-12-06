#!/usr/sbin/dtrace -s

/*
 *  args[] = 
 *  fct_cmd_t, cmd,
 *  fct_i_local_port_t, iport,
 *  scsi_task_t, task,
 *  fct_i_remote_port_t, irp);
 */
fc:::scsi-command
/((scsi_task_t *) arg2)->task_cdb[0] != 42
 && ((scsi_task_t *) arg2)->task_cdb[0] != 40
 && ((scsi_task_t *) arg2)->task_cdb[0] != 136
 && ((scsi_task_t *) arg2)->task_cdb[0] != 138/
{
	this->cmd = arg0;
	this->ilport = (fct_i_local_port_t *) arg1;
	this->task = (scsi_task_t *) arg2;
	this->rport = arg3;

	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

        @cmds[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	     this->task->task_cdb[0], this->task->task_cdb[1],
	     this->task->task_cdb[2], this->task->task_mgmt_function] = count();

        @cmd_total[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	     this->task->task_cdb[0], this->task->task_cdb[1],
	     this->task->task_cdb[2], this->task->task_mgmt_function] = count();
}

/*
 *  args[] = 
 *      fct_cmd_t, cmd,
 *      fct_i_local_port_t, (fct_i_local_port_t *)cmd->cmd_port->port_fct_private,
 *      scsi_task_t, task,
 *      fct_i_remote_port_t, (fct_i_remote_port_t *)cmd->cmd_rp->rp_fct_private);
 */
fc:::scsi-response
/((scsi_task_t *) arg2)->task_cdb[0] != 42
 && ((scsi_task_t *) arg2)->task_cdb[0] != 40
 && ((scsi_task_t *) arg2)->task_cdb[0] != 136
 && ((scsi_task_t *) arg2)->task_cdb[0] != 138
 && ((scsi_task_t *) arg2)->task_sense_data == NULL/
{
	this->cmd = arg0;
	this->ilport = (fct_i_local_port_t *) arg1;
	this->task = (scsi_task_t *) arg2;
	this->rport = arg3;

	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

        @resp_good[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	    this->task->task_cdb[0], this->task->task_scsi_status] = count();
        @resp_good_total[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	    this->task->task_cdb[0], this->task->task_scsi_status] = count();
}

/* 
 * Bad response
 */
fc:::scsi-response
/((scsi_task_t *) arg2)->task_cdb[0] != 42
 && ((scsi_task_t *) arg2)->task_cdb[0] != 40
 && ((scsi_task_t *) arg2)->task_cdb[0] != 136
 && ((scsi_task_t *) arg2)->task_cdb[0] != 138
 && (((scsi_task_t *) arg2)->task_sense_data)/
{
	this->cmd = arg0;
	this->ilport = (fct_i_local_port_t *) arg1;
	this->task = (scsi_task_t *) arg2;
	this->rport = arg3;

	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;
        @resp_bad[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	    this->task->task_cdb[0], this->task->task_sense_data[2],
	    this->task->task_sense_data[12], this->task->task_sense_data[13]] = count();
        @resp_bad_total[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	    this->task->task_cdb[0], this->task->task_sense_data[2],
	    this->task->task_sense_data[12], this->task->task_sense_data[13]] = count();

	@[stack()] = count();
}

profile:::tick-1s
{
	printf("\ncmds\n"); printa("%s,%s 0x%x 0x%x 0x%x %d	%@10d\n", @cmds);
	printf("good_resp\n"); printa("%s,%s 0x%x 0x%x %@10d\n", @resp_good);
	printf("bad_resp\n"); printa("%s,%s 0x%x 0x%x 0x0%x0%x %@10d\n", @resp_bad);

	trunc(@cmds, 0);
	trunc(@resp_good, 0);
	trunc(@resp_bad, 0);

}

END
{
	printf("\ntotal cmds\n"); printa("%s,%s 0x%x 0x%x 0x%x %d	%@15d\n", @cmd_total);
	printf("total good_resp\n"); printa("%s,%s 0x%x 0x%x %@15d\n", @resp_good_total);
	printf("total bad_resp\n"); printa("%s,%s 0x%x 0x%x 0x0%x0%x %@15d\n", @resp_bad_total);
	printa(@);
}
