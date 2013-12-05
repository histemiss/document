#some command use global init_net, and net could be calculated from task_struct, which need to set gdb var $task

define nfs_client_info
	set $nfs_client_info_tmp = (struct nfs_client *)$arg0
	set $nfs_client_info_state = $nfs_client_info_tmp->cl_state
	printf "nfs_client(%lx): rpc_clnt(%d), state(%d:", $nfs_client_info_tmp, $nfs_client_info_tmp->cl_rpcclient->cl_clid,$nfs_client_info_state

	if $nfs_client_info_state & (1<<NFS4CLNT_MANAGER_RUNNING) 
		printf "manager_running,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_CHECK_LEASE) 
		printf "check_lease,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_LEASE_EXPIRED) 
		printf "lease_expired,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_RECLAIM_REBOOT) 
		printf "reclaim_reboot,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_RECLAIM_NOGRACE) 
		printf "reclaim_nograce,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_DELEGRETURN) 
		printf "delegate_return,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_SESSION_RESET) 
		printf "session_reset,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_LEASE_CONFIRM) 
		printf "lease_confirm,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_SERVER_SCOPE_MISMATCH) 
		printf "server_scope_mismatch,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_PURGE_STATE) 
		printf "purge_state,"
	end
	if $nfs_client_info_state & (1<<NFS4CLNT_BIND_CONN_TO_SESSION) 
		printf "bind_conn_to_session,"
	end
	printf "),"

	printf "ds("
	set $nfs_client_info_ds = (struct list_head *) &$nfs_client_info_tmp->cl_ds_clients
	set $nfs_client_info_ds_index = $nfs_client_info_ds->next
	#nfs4_ds_server->list
	set $nfs_client_info_ds_list_offset = (unsigned long long) &(((struct nfs4_ds_server*)0)->list)

	while $nfs_client_info_ds_index - $nfs_client_info_ds
		printf "%d,",((struct nfs4_ds_server*)($nfs_client_info_ds_index-$nfs_client_info_ds_list_offset))->rpc_clnt->cl_clid
		set $nfs_client_info_ds_index = $nfs_client_info_ds_index->next
	end
	printf "),"

	printf "servers("
	set $nfs_client_info_sv = (struct list_head *) &$nfs_client_info_tmp->cl_superblocks
	set $nfs_client_info_sv_index = $nfs_client_info_sv->next
	#nfs_server->client_link
	set $nfs_client_info_sv_offset = (unsigned long long) &(((struct nfs_server*)0)->client_link)

	while $nfs_client_info_sv_index - $nfs_client_info_sv
		set $nfs_client_info_tmp_0 = (struct nfs_server*)((unsigned long long)$nfs_client_info_sv_index - $nfs_client_info_sv_offset)
		printf "nfs_server<%lx>|fsid<%d-%d>|", $nfs_client_info_tmp_0, $nfs_client_info_tmp_0->fsid.major, $nfs_client_info_tmp_0->fsid.minor
		printf "rpc<%d-%d>,", $nfs_client_info_tmp_0->client->cl_clid, $nfs_client_info_tmp_0->client_acl->cl_clid
		set $nfs_client_info_sv_index = $nfs_client_info_sv_index->next
	end
	printf "),"

	printf "\n"
end
	

define list_nfs_client
	#struct net 
        set $list_nfs_client_tmp = &init_net
	if $task 
		#printf "current task is %lx\n",$task
		set $list_nfs_client_tmp = ((struct task_struct *)$task)->nsproxy->net_ns
	end
	#printf "net is %lx\n",$list_nfs_client_tmp

	#struct net_generic
	set $list_nfs_client_tmp=((struct net*)$list_nfs_client_tmp)->gen
	#printf "net_generic is %lx\n", $list_nfs_client_tmp

	#nfs_net
	set $list_nfs_client_tmp = ((long long **)(struct net_generic*)$list_nfs_client_tmp->ptr)[nfs_net_id-1]
	#printf "nfs_net is %lx\n", $list_nfs_client_tmp

	#nfs_client_list
	set $list_nfs_client_tmp = (struct list_head *)&(((struct nfs_net *)$list_nfs_client_tmp)->nfs_client_list)
	set $list_nfs_client_tmp_index = $list_nfs_client_tmp->next
	set $list_nfs_client_tmp_offset = &(((struct nfs_client *)0)->cl_share_link)

	while $list_nfs_client_tmp_index - $list_nfs_client_tmp
		set $list_nfs_client_tmp_1 = (unsigned long long)$list_nfs_client_tmp_index - (unsigned long long)$list_nfs_client_tmp_offset
		nfs_client_info $list_nfs_client_tmp_1

		set $list_nfs_client_tmp_index = $list_nfs_client_tmp_index->next
	end
end

def rpc_clnt_info
	set $rpc_clnt_info_tmp = (struct rpc_clnt*)$arg0
	printf "rpc_clnt(%lx):id(%d),server(%s),name(%s),ver(%d)\n",$rpc_clnt_info_tmp,$rpc_clnt_info_tmp->cl_clid, $rpc_clnt_info_tmp->cl_xprt->servername, (char *)(($rpc_clnt_info_tmp->cl_program)->name), $rpc_clnt_info_tmp->cl_vers
end

define list_rpc_clnt
	#struct net 
        set $list_rpc_clnt_tmp = &init_net
	if $task 
		printf "current task is %lx\n",$task
		set $list_rpc_clnt_tmp = ((struct task_struct *)$task)->nsproxy->net_ns
	end
	#printf "net is %lx\n",$list_rpc_clnt_tmp
	
	#struct net_generic
	set $list_rpc_clnt_tmp=((struct net*)$list_rpc_clnt_tmp)->gen
	#printf "net_generic is %lx\n", $list_rpc_clnt_tmp

	#sunrpc_net
	set $list_rpc_clnt_tmp = ((long long **)(struct net_generic*)$list_rpc_clnt_tmp->ptr)[sunrpc_net_id-1]
	#printf "sunrpc_net is %lx\n", $list_rpc_clnt_tmp

	#all_clients
	set $list_rpc_clnt_tmp = (struct list_head *)&(((struct sunrpc_net*)$list_rpc_clnt_tmp)->all_clients)
	set $list_rpc_clnt_tmp_index = $list_rpc_clnt_tmp->next
	set $list_rpc_clnt_tmp_offset = (unsigned long long) &(((struct rpc_clnt*)0)->cl_clients)

	while $list_rpc_clnt_tmp_index - $list_rpc_clnt_tmp
		set $list_rpc_clnt_tmp_1 = (unsigned long long)$list_rpc_clnt_tmp_index - $list_rpc_clnt_tmp_offset
		rpc_clnt_info  $list_rpc_clnt_tmp_1
		set $list_rpc_clnt_tmp_index = $list_rpc_clnt_tmp_index->next
	end
end

define rpc_task_info
	set $rpc_task_info_tmp = (struct rpc_task *)$arg0
	printf "rpc_task(%lx):rpc_clnt(%d),id(%d),", $rpc_task_info_tmp, $rpc_task_info_tmp->tk_client->cl_clid, $rpc_task_info_tmp->tk_pid

	set $rpc_task_info_flag = $rpc_task_info_tmp->tk_flags
	printf "flags(%d,",$rpc_task_info_flag

	# RPC_TASK_ASYNC
	if $rpc_task_info_flag & 0x0001  
		printf "async,"
	end
	#RPC_TASK_SWAPPER
	if $rpc_task_info_flag & 0x0002
		printf "swapper,"
	end
	#RPC_CALL_MAJORSEEN
	if $rpc_task_info_flag & 0x0020
		printf "majorseen,"
	end
	#RPC_TASK_ROOTCREDS
	if $rpc_task_info_flag & 0x0040
		printf "root,"
	end
	#RPC_TASK_DYNAMIC
	if $rpc_task_info_flag & 0x0080
		printf "dynamic,"
	end
	#RPC_TASK_KILLED
	if $rpc_task_info_flag & 0x0100
		printf "killed,"
	end
	#RPC_TASK_SOFT
	if $rpc_task_info_flag & 0x0200
		printf "soft,"
	end
	#RPC_TASK_SOFTCONN
	if $rpc_task_info_flag & 0x0400
		printf "softconn,"
	end
	#RPC_TASK_SENT
	if $rpc_task_info_flag & 0x0800
		printf "sent,"
	end
	#RPC_TASK_TIMEOUT
	if $rpc_task_info_flag & 0x1000
		printf "tiemout,"
	end
	#RPC_TASK_NOCONNECT
	if $rpc_task_info_flag & 0x2000
		printf "noconnect,"
	end
	printf "),"

	set $rpc_task_info_runstate = $rpc_task_info_tmp->tk_runstate
	printf "runstate(%d,", $rpc_task_info_runstate
	#RPC_TASK_RUNNING
	if $rpc_task_info_runstate & ( 1<<0)
		printf "running,"
	end
	#RPC_TASK_QUEUED
	if $rpc_task_info_runstate & ( 1<<1)
		printf "queued,"
	end
	#RPC_TASK_ACTIVE
	if $rpc_task_info_runstate & ( 1<<2)
		printf "active,"
	end
	printf "),"
	printf "waitqueue(%lx),", $rpc_task_info_tmp->tk_waitqueue
	printf "\n"

end

define list_rpc_clnt_task
	set $rpc_clnt_task_tmp = (struct rpc_clnt*)$arg0
	set $rpc_clnt_task_tmp = (struct list_head *) &($rpc_clnt_task_tmp->cl_tasks)
	set $rpc_clnt_task_index = $rpc_clnt_task_tmp->next

	#rpc_task->tk_task
	set $rpc_clnt_task_offset = (unsigned long long ) &(((struct rpc_task*)0)->tk_task)

	while $rpc_clnt_task_index - $rpc_clnt_task_tmp
		set $rpc_clnt_task_tmp_0 = (struct rpc_task*)((unsigned long long)$rpc_clnt_task_index - $rpc_clnt_task_offset)
		rpc_task_info $rpc_clnt_task_tmp_0

		set $rpc_clnt_task_index = $rpc_clnt_task_index ->next
	end
end

define list_all_rpc_task
	#struct net 
        set $list_all_rpc_task_tmp = &init_net
	if $task 
		printf "current task is %lx\n",$task
		set $list_all_rpc_task_tmp = ((struct task_struct *)$task)->nsproxy->net_ns
	end
	#printf "net is %lx\n",$list_all_rpc_task_tmp
	
	#struct net_generic
	set $list_all_rpc_task_tmp=((struct net*)$list_all_rpc_task_tmp)->gen
	#printf "net_generic is %lx\n", $list_all_rpc_task_tmp

	#sunrpc_net
	set $list_all_rpc_task_tmp = ((long long **)(struct net_generic*)$list_all_rpc_task_tmp->ptr)[sunrpc_net_id-1]
	#printf "sunrpc_net is %lx\n", $list_all_rpc_task_tmp

	#all_clients
	set $list_all_rpc_task_tmp = (struct list_head *)&(((struct sunrpc_net*)$list_all_rpc_task_tmp)->all_clients)
	set $list_all_rpc_task_tmp_index = $list_all_rpc_task_tmp->next
	set $list_all_rpc_task_tmp_offset = (unsigned long long) &(((struct rpc_clnt*)0)->cl_clients)

	while $list_all_rpc_task_tmp_index - $list_all_rpc_task_tmp
		set $list_all_rpc_task_tmp_1 = (unsigned long long)$list_all_rpc_task_tmp_index - $list_all_rpc_task_tmp_offset
		rpc_clnt_info $list_all_rpc_task_tmp_1
		list_rpc_clnt_task $list_all_rpc_task_tmp_1
		print "\n"
		set $list_all_rpc_task_tmp_index = $list_all_rpc_task_tmp_index->next
	end
end
