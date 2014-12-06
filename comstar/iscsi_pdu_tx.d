#!/usr/sbin/dtrace -qs

/*
 * void idm_pdu_tx(idm_pdu_t *pdu)
 */
fbt:idm:idm_pdu_tx:entry
{
	this->pdu= (idm_pdu_t *) arg0;
	this->rsp = (iscsi_scsi_rsp_hdr_t *) this->pdu->isp_hdr;

        @cmds[ (uint8_t) this->rsp->opcode,
	    (uint8_t) this->rsp->cmd_status ] = count();

        @cmd_total[ (uint8_t) this->rsp->opcode,
	    (uint8_t) this->rsp->cmd_status ] = count();
}

profile:::tick-5s
{
	printf("\nopcode cmd_status\n"); printa("%d %d 	  %@10d\n", @cmds);
	trunc(@cmds, 0);
}

END
{
	printf("\nTotal \n");
	printa("%d %d	%@10d\n", @cmd_total);
}
