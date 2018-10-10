test `dirname "${0}"` = "${local_dir}" || {
    echo "Maybe a bug" >&2
    exit 1
}

. "${local_dir}/base.environments"

timestamp() {
    date '+%Y-%m-%dT%H%M%S%Z'
}


fail_if_exists() {
    test -e "${1}" && {
	error "Already exists: ${1}"
	return 1
    }

    return 0
}


mknewdir() {
    fail_if_exists "${1}" || return 1

    mkdir "${1}" || {
	error "Failed in mkdir ${1}"
	return 1
    }

    return 0
}


fail_unless_readable_file() {
    test -e "${1}" -a -f "${1}" -a -r "${1}" || {
	error "File ${1} has to exist, and to be read."
	return 1
    }

    return 0
}


fail_unless_writable_directory() {
    test -e "${1}" -a -d "${1}" -a -w "${1}" || {
	error "Directory ${1} has to exist, and to be written."
	return 1
    }
    
    return 0
}


to_stderr_n_file() {
    echo "[Error] ${2}" >&2

    echo "${2}" >> "${1}" || {
    	echo "[Error] Failed in echo ... >> ${1}" >&2
    	return 1
    }

    return 0
}


error() {
    to_stderr_n_file /dev/null "${1}" || return 1
    return 0
}
