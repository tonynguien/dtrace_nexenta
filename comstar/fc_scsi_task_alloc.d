#!/usr/sbin/dtrace -s

/*
 * fct_cmd_t *
 * fct_scsi_task_alloc(fct_local_port_t *port, uint16_t rp_handle,
 * uint32_t rportid, uint8_t *lun, uint16_t cdb_length,
 *  uint16_t task_ext)
 */
fbt::fct_scsi_task_alloc:entry
{
	self->trace = 1;
	this->lport = (fct_local_port_t *) arg0;
	this->lun = (uint8_t *) arg3;
	luNbr = ((uint16_t)this->lun[1] | (((uint16_t)(this->lun[0] & 0x3F)) << 8));

	printf("Lport:%s LU:%d  rportid:%d", stringof(this->lport->port_nwwn_str),
	    luNbr, arg2);
}

/*
 * struct scsi_task *
 * stmf_task_alloc(struct stmf_local_port *lport, stmf_scsi_session_t *ss,
 * uint8_t *lun, uint16_t cdb_length_in, uint16_t ext_id)
 */
fbt::stmf_task_alloc:entry
/self->trace/
{
	self->trace_alloc = 1;
	this->ss = (stmf_scsi_session_t *) arg1;
	this->lun = (uint8_t *) arg2;
	luNbr = ((uint16_t)this->lun[1] | (((uint16_t)(this->lun[0] & 0x3F)) << 8));

	printf("rport_alias:%s LU:%d", stringof(this->ss->ss_rport_alias), luNbr);
}

fbt::stmf_alloc:entry
/self->trace && self->trace_alloc/
{
	printf("alloc struct:%d length:%d", arg0, arg1);
}

fbt::stmf_task_alloc:return
/self->trace && self->trace_alloc/
{
	self->trace_alloc = 0;
	this->task = (scsi_task_t *) arg1;
        this->session = (stmf_scsi_session_t *) this->task->task_session;
        this->isession = (stmf_i_scsi_session_t *) this->session->ss_stmf_private;
        this->irport= (fct_i_remote_port_t *) this->session->ss_port_private;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

        n = ((uint16_t)this->task->task_lun_no[1] | (((uint16_t)(this->task->task_lun_no[0] & 0x3F)) << 8));

        printf("task:%p rp_pwwn:%s lun_no: %d  cdb:0x%02X 0x%02X %02X\n", arg1, stringof(this->rport->rp_pwwn_str),
            n, this->task->task_cdb[0], this->task->task_cdb[1], this->task->task_cdb[2]);
}

fbt::fct_scsi_task_alloc:return
/self->trace/
{
	self->trace = 0;
}
