#!/usr/sbin/dtrace -s

fbt:stmf:stmf_scsilib_handle_report_tpgs:entry
/((sbd_lu_t *) args[0]->task_lu->lu_provider_private)->sl_name == "/dev/zvol/rdsk/tank3/zvol1" /
{
        self->tr = 1;
}


fbt:stmf:stmf_prepare_tpgs_data:return
/self->tr/
{
        this->xd = (stmf_xfer_data_t *) arg1;
        /* printf("0x%x \n", (uint16_t) this->xd->buf[0]); */
        tracemem(this->xd->buf, 50);
}

fbt:stmf:stmf_scsilib_handle_report_tpgs:return
/self->tr/ { self->tr = 0; }
