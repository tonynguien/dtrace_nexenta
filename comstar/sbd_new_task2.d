#!/usr/sbin/dtrace -s

#pragma D option flowindent

fbt::sbd_new_task:entry
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

	n = ((uint16_t)this->task->task_lun_no[1] | (((uint16_t)(this->task->task_lun_no[0] & 0x3F)) << 8));
/* sbd_lu_t *sl = (sbd_lu_t *)task->task_lu->lu_provider_private; */

	printf("task:%p rp_pwwn:%s lun_no: %d  cdb:0x%02X 0x%02X %02X\n", arg0, stringof(this->rport->rp_pwwn_str),
	    n, this->task->task_cdb[0], this->task->task_cdb[1], this->task->task_cdb[2]);
	/* tracemem(this->task->task_cdb, 28); */
}

fbt::stmf_register_itl_handle:entry
/self->tr/
{}

fbt::stmf_register_itl_handle:return
/self->tr/
{
	printf("arg0:0x%x  arg1:0x%02X\n", arg0, arg1);
}

fbt::stmf_get_ent_from_map:entry
/self->tr/
{
	this->sm = (stmf_lun_map_t *) arg0;
	printf("lm_nentries: %d  lun_num: %d\n", this->sm->lm_nentries, arg1);

}

fbt::sbd_new_task:return
/self->tr/
{
	self->tr = 0;
	printf("arg0:0x%x  arg1:0x%02X\n", arg0, arg1);
}
