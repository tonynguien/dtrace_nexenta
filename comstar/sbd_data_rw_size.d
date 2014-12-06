#!/usr/sbin/dtrace -s

/*
fbt:stmf_sbd:sbd_data_read:entry
{ @rsize[ (uint64_t) arg3] = count(); }

fbt:stmf_sbd:sbd_data_write:entry
{ @wsize[ (uint64_t) arg3] = count(); }
*/

fbt:stmf_sbd:sbd_do_sgl_read_xfer:entry
{ @rsize[ (uint64_t) args[1]->len, args[2] ] = count(); }
/* /args[2]/ { @rsize[ (uint64_t) args[1]->len, args[2] ] = count(); } */

fbt:stmf_sbd:sbd_do_sgl_write_xfer:entry
{ @wsize[ (uint64_t) args[1]->len, args[2] ] = count(); } 
/* /args[2]/ { @wsize[ (uint64_t) args[1]->len, args[2] ] = count(); } */

profile:::tick-1sec
{
	printa("\nReads:%d  %d	%@-6d", @rsize); trunc(@rsize);
	printa("\nWrites:%d %d	%@-6d", @wsize); trunc(@wsize);
}
