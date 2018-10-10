#!/bin/sh

readonly local_dir=`dirname "${0}"`

. "${local_dir}/common.sh"

readonly log_dir="${LOGS_DIR}/send-studies."`timestamp`
mknewdir "${log_dir}" || exit 1

readonly sum_log_file="${log_dir}.summary.log"
fail_if_exists "${sum_log_file}" || exit 1

error() {
    to_stderr_n_file "${sum_log_file}" "$1" || exit 1
}

for src_zip in "$@"
do
    echo -n `timestamp`" ${src_zip} " >> "${sum_log_file}"

    src_zip_bn=`basename "${src_zip}" | sed 's|\.zip||i'`

    err_file="${log_dir}/${src_zip_bn}."`timestamp`'.err'
    fail_if_exists "${err_file}" || exit 1

    "${local_dir}/send-a-study.sh" "${src_zip}" "${log_dir}" 2> "${err_file}" || {
	error "Failed in ${local_dir}/send-a-study.sh ${src_zip} ${log_dir} 2> ${err_file}"
	error "See ${err_file}"
	cat "${err_file}" >&2
	exit 1
    }

    if test -s "${err_file}"
    then
	echo 'Bug?' >&2
    else
	:
	# rm "${err_file}"
    fi

    echo `timestamp`' [Succeeded]' >> "${sum_log_file}" || exit 1
done || exit 1

echo `timestamp`' [Succeeded all]' >> "${sum_log_file}" || exit 1

exit 0
