#!/usr/sbin/dtrace -s

#pragma D option quiet

zfs:hdr_dest:entry {self->ts = timestamp; }
zfs:hdr_dest:return
/self->ts/ { @[probefunc] = quantize((timestamp/1000/1000) - (self->ts/1000/1000)); }

profile:::tick-5sec
{ printa(@); trunc(@); }
