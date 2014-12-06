#!/usr/sbin/dtrace -s

fbt:mpt_sas:mptsas_start_cmd:entry
{
        self->cmd = (mptsas_cmd_t *) arg1;
	@[self->cmd->cmd_active_timeout] = count();
}

profile:::tick-5s
{
	printa(@);
}

