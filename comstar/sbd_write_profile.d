#!/usr/sbin/dtrace -Fs

#pragma option flowindent

fbt:stmf_sbd:sbd_handle_write:entry
{
self->tr = 1 ;
}

fbt:stmf_sbd::entry
/self->tr/
{ }

fbt:stmf_sbd::return
/self->tr/
{ }

fbt:stmf_sbd:sbd_handle_write:return
/self->tr/
{
	self->tr = 0 ;
	exit(0) ;
}
