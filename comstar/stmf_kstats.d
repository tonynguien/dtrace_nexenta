#!/usr/sbin/dtrace -s

/*
 * static void
 * stmf_teardown_itl_kstats(stmf_i_itl_kstat_t *ks)
 *
  typedef struct stmf_i_itl_kstat {
        char                    iitl_kstat_nm[KSTAT_STRLEN];
        char                    iitl_kstat_lport[STMF_TGT_NAME_LEN];
        char                    iitl_kstat_guid[STMF_GUID_INPUT + 1];
        char                    *iitl_kstat_strbuf;
        int                     iitl_kstat_strbuflen;
        kstat_t                 *iitl_kstat_info;
        kstat_t                 *iitl_kstat_taskq;
        kstat_t                 *iitl_kstat_lu_xfer;
        kstat_t                 *iitl_kstat_lport_xfer;
        avl_node_t              iitl_kstat_ln;
  } stmf_i_itl_kstat_t;
 *
 */

ftb:stmf:stmf_teardown_itl_kstats:entry
{
	this->itl_ks = (stmf_i_itl_kstat_t *) arg0;

	@s[stacks() = count();
	@[walltimestamp, probefunc,
	    this->itl_ks->iitl_kstat_guid,
	    this->itl_ks->iitl_kstat_lport] = count(); 
}

profile:::tick-1sec
{
	printa("%Y %s %s %s %@d@", @);
	printa(@s);
}
