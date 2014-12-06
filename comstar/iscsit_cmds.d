#!/usr/sbin/dtrace -qs

/*
 * DTRACE_ISCSI_2(scsi__response,
 * idm_conn_t *, ic,
 * iscsi_scsi_rsp_hdr_t *, (iscsi_scsi_rsp_hdr_t *)pdu->isp_hdr);
 */
iscsi:idm::scsi-response
{
	this->conn = (idm_conn_t *) arg0;
	this->rsp = (iscsi_scsi_rsp_hdr_t *) arg1;

        @cmds[ (uint8_t) this->rsp->opcode,
	    (uint8_t) this->rsp->cmd_status,
	    (uint8_t) this->rsp->response ] = count();

        @cmd_total[ (uint8_t) this->rsp->opcode,
	    (uint32_t) this->rsp->expcmdsn,
	    (uint32_t) this->rsp->expdatasn,
	    (uint8_t) this->rsp->cmd_status,
	    (uint8_t) this->rsp->response ] = count();

	/* Get LUN info
	this->task_lu = (stmf_lu_t *) this->task->task_lu; 
	this->sl = (sbd_lu_t *) this->task_lu->lu_provider_private;

        @cmds[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	     this->task->task_cdb[0], this->task->task_cdb[1],
	     this->task->task_mgmt_function] = count();

        @cmd_total[stringof(this->ilport->iport_alias), stringof(this->sl->sl_name),
	     this->task->task_cdb[0], this->task->task_cdb[1],
	     this->task->task_mgmt_function] = count();
	*/
}

/*
 * DTRACE_ISCSI_2(data__send, idm_conn_t *, ic,
 *  iscsi_data_rsp_hdr_t *, (iscsi_data_rsp_hdr_t *)pdu->isp_hdr);
 */
iscsi:idm:idm_pdu_tx:data-send
{
	this->conn = (idm_conn_t *) arg0;
	this->rsp = (iscsi_scsi_rsp_hdr_t *) arg1;

        @data[ (uint8_t) this->rsp->opcode,
	    (uint8_t) this->rsp->cmd_status ] = count();

        @data_total[ (uint8_t) this->rsp->opcode,
	    (uint32_t) this->rsp->expcmdsn,
	    (uint32_t) this->rsp->expdatasn,
	    (uint8_t) this->rsp->cmd_status ] = count();
}

profile:::tick-5s
{
	printf("\nCmds: opcode cmd_status response\n"); printa("%d %d %d	%@10d\n", @cmds);
	printf("\nData: opcode cmd_status\n"); printa("%d %d 	%@10d\n", @data);
	
	/*
	printf("good_resp\n"); printa("%s,%s 0x%x 0x%x %@10d\n", @resp_good);
	printf("bad_resp\n"); printa("%s,%s 0x%x 0x%x 0x0%x0%x %@10d\n", @resp_bad);
	trunc(@resp_good, 0);
	trunc(@resp_bad, 0);
	*/
	trunc(@cmds, 0);
}

END
{
	printf("\nCmds: opcode expcmdsn expdatasn cmd_status response\n");
	printa("%d %d %d %d %d	%@10d\n", @cmd_total);
	printf("\nData: opcode expcmdsn expdatasn cmd_status\n");
	printa("%d %d %d %d	%@10d\n", @data_total);

	/*
	printf("total good_resp\n"); printa("%s,%s 0x%x 0x%x %@15d\n", @resp_good_total);
	printf("total bad_resp\n"); printa("%s,%s 0x%x 0x%x 0x0%x0%x %@15d\n", @resp_bad_total);
	printa(@);
	*/
}
