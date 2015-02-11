#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
zio_buf_alloc:entry,
zio_data_buf_alloc:entry
/args[0] == 0x200 || args[0] == 0x4000/
{
	@[probefunc, args[0], stack()] = count();
}*/

zio_buf_alloc:entry
{ @meta = quantize(args[0]); }

zio_data_buf_alloc:entry
{ @data = quantize(args[0]); }

profile:::tick-10sec
{
	printf("%Y\n", walltimestamp);
	printf("Metadata"); printa(@meta);
	printf("Data"); printa(@data);
	clear(@meta); clear(@data);
}
