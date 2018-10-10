#!/bin/sh

readonly local_dir=`dirname "${0}"`

. "${local_dir}/common.sh"

readonly study_list_file=`ls -1 "${WORK_DIR}"/study-list.????-??-??T??????*.tsv | tail -1`
fail_unless_readable_file "${study_list_file}" || exit 1

readonly log_dir="${LOGS_DIR}/archive-studies."`timestamp`'.'`basename "${study_list_file}" .tsv | sed --posix 's|^study-list\.||'`
mknewdir "${log_dir}" || exit 1

readonly sum_log_file="${log_dir}.summary.log"
fail_if_exists "${sum_log_file}" || exit 1

error() {
    to_stderr_n_file "${sum_log_file}" "$1" || exit 1
}

while read study
do
    uid=`echo "${study}" | cut -f1`
    count=`echo "${study}" | cut -f2`
    name=`echo "${study}" | cut -f3`

    echo -n `timestamp`" ${study} " >> "${sum_log_file}"

    err_file="${log_dir}/${uid}.err"
    fail_if_exists "${err_file}" || exit 1

    result=$( "${local_dir}/archive-a-study.sh" "${uid}" "${name}" "${log_dir}" 2> "${err_file}" ) || {
	error "Failed in ${local_dir}/archive-a-study.sh ${uid} ${name} ${log_dir} 2> ${err_file}"
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

    test "${result}" -eq "${count}" || {
	error "Instance count mismatch: ${result} retrieved whilst ${count} queried"
	exit 1
    }

    echo `timestamp`' [Succeeded]' >> "${sum_log_file}" || exit 1
done < "${study_list_file}" || exit 1

echo `timestamp`' [Succeeded all]' >> "${sum_log_file}" || exit 1

exit 0
