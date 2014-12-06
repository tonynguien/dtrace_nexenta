#!/usr/sbin/dtrace -s

/* VAAI 
 * Full Copy: sbd_handle_xcopy -> cpmgr ->
 * Block Zero: sbd_handle_write_same
 * ATS: sbd_handle_ats
 */
fbt:stmf_sbd:sbd_handle_xcopy_xfer:entry
{
	self->tr = 1;
}

fbt:stmf_sbd::entry
/self->tr/
{
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_handle_xcopy_xfer:return
/self->tr/
{
	self->tr = 0;
	printa(@); trunc(@);
}
