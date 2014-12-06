#!/usr/sbin/dtrace -s

#pragma option flowindent

fbt:stmf_sbd:sbd_handle_inquiry:entry
/((scsi_task_t *) arg0)->task_cdb[2] == 0x80/
{
self->tr = 1 ;
}

fbt:stmf_sbd:sbd_handle_inquiry:entry
/self->tr/
{ }

fbt::ddi_prop_lookup_string:entry
/self->tr/
{ }

fbt::ddi_prop_lookup_string:return
/self->tr/
{ }

fbt:stmf_sbd:sbd_handle_short_read_transfers:entry
/self->tr/
{ }

fbt:stmf_sbd:sbd_handle_short_read_transfers:return
/self->tr/
{ }

fbt:stmf_sbd:sbd_handle_inquiry:return
/self->tr/
{
self->tr = 0 ;
}

