#!/usr/sbin/dtrace -s

#pragma D option flowindent

fbt:stmf_sbd:sbd_data_read:entry
{
self->tr = 1 ;
}

fbt::vn_rdwr:entry
/self->tr/
{
	self->vn = timestamp;
}

fbt:::entry
/self->tr && self->vn/
{ }

fbt:::return
/self->tr && self->vn/
{ }

fbt::vn_rdwr:return
/self->tr && self->vn/
{
	self->vn = 0;
}

fbt:stmf_sbd:sbd_data_read:return
/self->tr/
{
self->tr = 0 ;
exit(0) ;
}
