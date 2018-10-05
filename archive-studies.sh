#!/bin/sh

local_dir=$( dirname "${0}" )

. "${local_dir}/common.sh"

study_list_file=$(ls -1 "${WORK_DIR}"/study-list.????-??-??T??????*.tsv | tail -1)
if test -e "${study_list_file}" -a -f "${study_list_file}" -a -r "${study_list_file}"
then
    :
else
    echo "[Error] File ${study_list_file} has to exist, and to be read." >&2
    exit 1
fi

log_dir="${LOGS_DIR}/archive-studies."$( timestamp )'.'$( basename "${study_list_file}" .tsv | sed --posix 's|^study-list\.||' )

sum_log_file="${log_dir}.summary.log"
if test -e "${sum_log_file}"
then
    echo "[Error] Already exists: ${sum_log_file}" >&2
    exit 1
fi

error() {
    echo "[Error] $1" >&2
    echo "$1" >> "${sum_log_file}" || exit 1
    if [ $? -ne 0 ]
    then
    	echo "[Error] Failed in echo ... >> ${sum_log_file}" >&2
    	exit 1
    fi
}

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

while read study
do
    uid=$( echo "${study}" | cut -f1 )
    count=$( echo "${study}" | cut -f2 )
    name=$( echo "${study}" | cut -f3 )

    echo -n $( timestamp )" ${study} " >> "${sum_log_file}"

    err_file="${log_dir}/${uid}.err"
    if test -e "${err_file}"
    then
	error "Already exists: ${err_file}"
	exit 1
    fi

    result=$( "${local_dir}/archive-a-study.sh" "${uid}" "${name}" "${log_dir}" 2> "${err_file}" )

    if [ $? -ne 0 ]
    then
	error "Failed in ${local_dir}/archive-a-study.sh ${uid} ${name} ${log_dir} 2> ${err_file}"
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

    if expr "${result}" != "${count}" > /dev/null
    then
	error "Instance count mismatch: ${result} retrieved whilst ${count} queried"
	exit 1
    fi

    echo $( timestamp )' [Succeeded]' >> "${sum_log_file}" || exit $?
done < "${study_list_file}" || exit $?

echo $( timestamp )' [Succeeded all]' >> "${sum_log_file}" || exit $?

exit 0
