#!/bin/sh

local_dir=$( dirname "${0}" )

. "${local_dir}/common.sh"

log_dir="${LOGS_DIR}/send-studies."$( timestamp )
mklogdir "${log_dir}" || exit 1

sum_log_file="${log_dir}.summary.log"
if test -e "${sum_log_file}"
then
    echo "[Error] Already exists: ${sum_log_file}" >&2
    exit 1
fi

error() {
    to_stderr_n_file "${sum_log_file}" "$1" || exit 1
}

for src_zip in "$@"
do
    echo -n $( timestamp )" ${src_zip} " >> "${sum_log_file}"

    src_zip_bn=$( basename "${src_zip}" | sed 's|\.zip||i' )

    err_file="${log_dir}/${src_zip_bn}."$( timestamp )'.err'
    if test -e "${err_file}"
    then
	error "Already exists: ${err_file}"
	exit 1
    fi

    "${local_dir}/send-a-study.sh" "${src_zip}" "${log_dir}" 2> "${err_file}"

    if [ $? -ne 0 ]
    then
	error "Failed in ${local_dir}/send-a-study.sh ${src_zip} ${log_dir} 2> ${err_file}"
	error "See ${err_file}"
	exit 1
    fi

    if test -s "${err_file}"
    then
	:
    else
	:
	# rm "${err_file}"
    fi

    echo $( timestamp )' [Succeeded]' >> "${sum_log_file}" || exit $?
done || exit $?

echo $( timestamp )' [Succeeded all]' >> "${sum_log_file}" || exit $?

exit 0
