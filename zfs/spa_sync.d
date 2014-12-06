#!/usr/sbin/dtrace -qs

fbt:zfs:spa_sync:entry
/args[0]->spa_name == $$1/
{
	self->traceme = 1;
	self->tr = timestamp;
}

/*
fbt:::entry
/self->traceme/
{ @[probefunc] =  count(); }
*/

fbt:zfs:spa_sync:return
/self->traceme/
{
	@spa_sync = quantize((timestamp - self->tr) / 1000);
	self->traceme = 0;
}

profile:::tick-10s
{
	printf("\nLatencies"); printa(@spa_sync);

	/* printf("Callees"); printa(@);*/
}
