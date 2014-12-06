#!/usr/sbin/dtrace -qs

fbt:qlt:qlt_handle_atio_queue_update:entry
{
	this->qlt_ts = timestamp;
	@[probefunc] = count();
}

fbt::stmf_post_task:entry
/this->qlt_ts/
{
	this->post_task = 1;
	@tasks = count();

	@[probefunc] = count();
}

fbt:qlt:qlt_handle_atio_queue_update:return
/this->qlt_ts && this->post_task/
{
	@setup = avg(timestamp - this->qlt_ts);

	this->post_task = 0;
	this->qlt_ts = 0;
}

profile:::tick-5s
{
	printf("\n=== probe sumamry ====");
        printa(@); trunc(@, 0);
	
	printf("\n=== Avg qlt set up time (us)====");
        printa(@setup); trunc(@setup, 0);

	printf("\n=== posted tasks / sec ====");
	normalize(@tasks, 5);
        printa(@tasks); trunc(@tasks, 0);
}

