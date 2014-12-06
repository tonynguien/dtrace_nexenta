#!/usr/sbin/dtrace -s

fbt:mpt_sas:mptsas_scsi_start:entry
{self->tr = 1;}

fbt:mpt_sas:mptsas_accept_txwq_and_pkt:entry
/self->tr/
{
        this->mpt = (mptsas_t *) arg0;
        this->cmd = (mptsas_cmd_t *) arg1;
        this->ptgt = (mptsas_target_t *) this->cmd->cmd_tgt_addr;
        this->cmd_cdb = (uint8_t *) this->cmd->cmd_cdb;

        printf("%s doneq_thread_n:%d cmd:%d target_wwn:%x\n", probefunc,
            this->mpt->m_doneq_thread_n, this->cmd_cdb[0], this->ptgt->m_sas_wwn);
}

fbt:mpt_sas:mptsas_accept_txwq_and_pkt:return
/self->tr/ { printf("%s  retval:%d\n", probefunc, arg1); }

fbt:mpt_sas:mptsas_scsi_start:return
/self->tr/ {self->tr = 0; printf("%s ret:%d\n", probefunc, arg1);}
