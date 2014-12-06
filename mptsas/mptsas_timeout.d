#!/usr/sbin/dtrace -s

fbt:mpt_sas:mptsas_start_cmd:entry
{
        self->cmd = (mptsas_cmd_t *) arg1;
        /*printf("cmd_active_timeout: %d", self->cmd->cmd_active_timeout); */

        self->tgt = (mptsas_target_t *) self->cmd->cmd_tgt_addr;
        printf(" tgt m_timeout: %d",  self->tgt->m_timeout);
        printf(" tgt m_timebase: %d", self->tgt->m_timebase);
}

fbt:mpt_sas:mptsas_start_cmd:return
{
        self->tgt = (mptsas_target_t *) self->cmd->cmd_tgt_addr;
        printf(" tgt m_timeout: %d",  self->tgt->m_timeout);
        printf(" tgt m_timebase: %d", self->tgt->m_timebase);
}

