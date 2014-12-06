#!/usr/sbin/dtrace -s

iscsi:::xfer-start
{
	self->ts = timestamp;
	@events[args[0]->ci_remote, probename] = count();
}

iscsi:::xfer-done
/self->ts/
{
	@events[args[0]->ci_remote, probename] = count();

        /* usec */
        @q = quantize((timestamp - self->ts) / 1000);
        
	self->ts =0;
}

profile:::tick-10s
{
        printf("Values in usec\n");
        printa(@q);
        trunc(@q, 0);
}

