#!/usr/sbin/dtrace -s

fbt::stmf_dlun0_new_task:entry
/((scsi_task_t *) arg0)->task_cdb[0] != 0x0/ 	/* for some strange reason, OSX sends 0x0 cmd to dlun0 */
{
	self->tr = 1;
	this->task = (scsi_task_t *) arg0;
	this->lport = (stmf_local_port_t *) this->task->task_lport;
	this->port = (fct_local_port_t *) this->lport->lport_port_private;
	this->session = (stmf_scsi_session_t *) this->task->task_session;
	this->isession = (stmf_i_scsi_session_t *) this->session->ss_stmf_private;
	this->irport= (fct_i_remote_port_t *) this->session->ss_port_private;
	this->rport= (fct_remote_port_t *) this->irport->irp_rp;

	printf("rp_pwwn: %s   cdb: %02X %02X %02X\n", stringof(this->rport->rp_pwwn_str),
	    this->task->task_cdb[0], this->task->task_cdb[1], this->task->task_cdb[2]);
	/* tracemem(this->task->task_cdb, 28); */
}

fbt::stmf_session_prepare_report_lun_data:entry
/self->tr/
{
	@[probefunc] = count();

	this->lmap = (stmf_lun_map_t *) arg0;
	printf("lm_nluns: %d lm_nentries: %d\n", this->lmap->lm_nluns, this->lmap->lm_nentries);
   	tracemem(this->lmap, 50);
}

fbt::stmf_xd_to_dbuf:entry
/self->tr/
{
	 @[probefunc] = count();
}

fbt::stmf_xfer_data:entry
/self->tr/
{
	 @[probefunc] = count();
}

fbt::stmf_dlun0_new_task:return
/self->tr/
{
	self->tr = 0;
	printa(@); trunc(@);
}
