#!/usr/sbin/dtrace -s

fbt::ql_done:entry
{ self->tr = 1; }

fbt:qlc:*:entry
/self->tr/ {@[probefunc]=count(); stack(); }

fbt::ql_done:return
/self->tr/ { self->tr = 0; }

