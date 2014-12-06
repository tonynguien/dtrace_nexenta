#!/usr/sbin/dtrace -s

#pragma option flowindent

fbt:stmf_sbd:sbd_data_read:entry


fbt:stmf_sbd:sbd_data_read:entry
{
self->tr = 1;
}

fbt:stmf*::
/self->tr/
{

}

fbt:stmf_sbd:sbd_data_read:return
{
self->tr = 0;
exit(0);
}
