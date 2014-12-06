dtrace -s

fbt:iscsit:login_sm_session_bind:entry
{
	self->trace=1;
}

fbt:iscsit::entry
/self->trace/
{
	@[probefunc] = count();
}

fbt:iscsit:login_sm_session_bind:return
{
	self->trace=0;
	printf("offset: %x   retval: %d", arg0, arg1);
}
