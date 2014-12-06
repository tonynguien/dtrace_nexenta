#!/usr/sbin/dtrace -qs

fbt:iscsit:login_sm_session_bind:entry
{
	this->ict = (iscsit_conn_t *) arg0;
	this->lsm = (iscsit_conn_login_t) this->ict->ict_login_sm;

	printf("\nTarget name: %s\n", this->lsm.icl_target_name ? this->lsm.icl_target_name : "empty");
	printf("Initiator name: %s   TSIH: 0x%04x   cmdSN: 0x%08x",
	    stringof(this->lsm.icl_initiator_name), this->lsm.icl_tsih, this->lsm.icl_cmdsn);
	printf("    ISID: 0x%02x%02x%02x%02x%02x%02x\n", this->lsm.icl_isid[0], this->lsm.icl_isid[1],
	    this->lsm.icl_isid[2], this->lsm.icl_isid[3], this->lsm.icl_isid[4], this->lsm.icl_isid[5]);
}
