#!/bin/sh

. $( dirname "${0}" )/common.sh

uid="$1"
name="$2"
log_dir="$3"

if [ 'x' != 'x'$( echo "${uid}" | sed --posix 's|^[0-9\.]*$||' ) ]
then
    echo "[Error] UID ${uid} in unknown format" >&2
    exit 1
fi

dest_dir="${WORK_DIR}/archive.${uid}".$( timestamp )

if test -e "${dest_dir}"
then
    echo "[Error] Already exists: ${dest_dir}" >&2
    exit 1
fi

if [ 'x' = "x${name}" ]
then
    echo "[Error] archive name ${name} is empty" >&2
    exit 1    
fi

zip_file="${ARCH_DIR}/${name}.zip"

if test -e "${zip_file}"
then
    echo "[Error] Already exists: ${zip_file}" >&2
    exit 1
fi

if test -e "${log_dir}" -a -d "${log_dir}" -a -w "${log_dir}"
then
    :
else
    echo "[Error] Directory ${log_dir} has to exist, and to be written." >&2
    exit 1
fi

storescp_out="${log_dir}/${uid}.storescp.out"

if test -e "${storescp_out}"
then
    echo "[Error] Already exists: ${storescp_out}" >&2
    exit 1
fi

movescu_out="${log_dir}/${uid}.movescu.out"

if test -e "${movescu_out}"
then
    echo "[Error] Already exists: ${movescu_out}" >&2
    exit 1
fi

mkdir "${dest_dir}"
if [ $? -ne 0 ]
then
    echo "[Error] Failed in mkdir ${dest_dir}" >&2
    exit 1
fi

"${DCM4CHE5}/bin/storescp" \
    --bind "${RETV_AET}" --directory "${dest_dir}" \
    --accept-unknown \
    > "${storescp_out}" &

storescp_pid=$!

rcvaet=$( echo "${RETV_AET}" | sed --posix 's:@.*$::' )

"${DCM4CHE5}/bin/movescu" \
    --connect "${SEND_AET}" --bind "${RETV_AET}" --dest "${rcvaet}" \
    -m 0020000D="${uid}" \
    > "${movescu_out}"

movescu_exitcode=$?

kill -s TERM ${storescp_pid}

wait ${storescp_pid}

if [ $? -ne 143 ]
then
    echo "[Error] ${DCM4CHE5}/bin/storescp ... exited in not 130" >&2
    exit 1
fi

if [ ${movescu_exitcode} -ne 0 ]
then
    echo "[Error] Failed in ${DCM4CHE5}/bin/movescu ..." >&2
fi

file_count=$( ls -1 "${dest_dir}" | wc -l )

if [ ${file_count} -gt 0 ]
then
    (
	cd "${dest_dir}"

	zip --quiet -0 "${zip_file}" *

	if [ $? -ne 0 ]
	then
	    echo "[Error] Failed in zip --quiet -0 ${zip_file} *" >&2
	    exit 1
	fi
    ) || exit $?

    zip --quiet --test "${zip_file}"

    if [ $? -ne 0 ]
    then
	echo "[Error] Failed in zip --quiet --test ${zip_file}" >&2
	exit 1
    fi

    rm "${dest_dir}"/*

    if [ $? -ne 0 ]
    then
	echo "[Error] Failed in rm ${dest_dir}/*" >&2
	exit 1
    fi
fi

rmdir "${dest_dir}"
if [ $? -ne 0 ]
then
    echo "[Error] Failed in rmdir ${dest_dir}" >&2
    exit 1
fi

# rm "${storescp_out}"
# rm "${movescu_out}"

echo ${file_count}

exit 0
