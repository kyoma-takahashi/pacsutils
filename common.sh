. $( dirname "${0}" )/base.environments

timestamp() {
    date '+%Y-%m-%dT%H%M%S%Z'
}


mklogdir() {
    log_dir="$1"

    if test -e "${log_dir}"
    then
	error "Already exists: ${log_dir}"
	exit 1
    fi

    mkdir "${log_dir}"
    if [ $? -ne 0 ]
    then
	error "Failed in mkdir ${log_dir}"
	exit 1
    fi
}


to_stderr_n_file() {
    errfile="$1"
    message="$2"

    echo "[Error] ${message}" >&2
    echo "${message}" >> "${errfile}"
    if [ $? -ne 0 ]
    then
    	echo "[Error] Failed in echo ... >> ${errfile}" >&2
    	exit 1
    fi
}
