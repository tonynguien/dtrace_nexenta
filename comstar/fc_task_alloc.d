#!/usr/sbin/dtrace -qs

/*
 * struct scsi_task *
 * stmf_task_alloc(struct stmf_local_port *lport, stmf_scsi_session_t *ss,
 * uint8_t *lun, uint16_t cdb_length_in, uint16_t ext_id)
 */
fbt::stmf_task_alloc:entry
{
        self->tr = 1;
        this->ss = (stmf_scsi_session_t *) arg1;
        this->lun = (uint8_t *) arg2;
        self->luNbr = ((uint16_t)this->lun[1] | (((uint16_t)(this->lun[0] & 0x3F)) << 8));
        /*printf("LU: %-4d ", luNbr); */
}

fbt::stmf_alloc:entry
/self->tr/ { self->new = 1; }


fbt::stmf_task_alloc:return
/self->tr/
{
        self->tr = 0;
        self->new = 0;
        this->task = (scsi_task_t *) arg1;
        this->session = (stmf_scsi_session_t *) this->task->task_session;
        this->isession = (stmf_i_scsi_session_t *) this->session->ss_stmf_private;
        this->irport= (fct_i_remote_port_t *) this->session->ss_port_private;
        this->rport= (fct_remote_port_t *) this->irport->irp_rp;

        n = ((uint16_t)this->task->task_lun_no[1] | (((uint16_t)(this->task->task_lun_no[0] & 0x3F)) << 8));

        printf("LU: %-4d lun_no: %-4d new: %d task:%p rp_pwwn:%s cdb:0x%02X 0x%02X %02X\n",
            self->luNbr, n, self->new ? 1 : 0, arg1,
            stringof(this->rport->rp_pwwn_str), this->task->task_cdb[0],
            this->task->task_cdb[1], this->task->task_cdb[2]);
}

