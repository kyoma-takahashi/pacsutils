#!/bin/sh

readonly local_dir=`dirname "${0}"`

. "${local_dir}/common.sh"

readonly uid="$1"
readonly name="$2"
readonly log_dir="$3"

test 'x' = `echo "${uid}" | sed --posix 's|^[0-9\.]*$|x|'` || {
    error "UID ${uid} in unknown format"
    exit 1
}

test 'x' = "x${name}" && {
    error "archive name ${name} is empty"
    exit 1
}

readonly zip_file="${ARCH_DIR}/${name}.zip"
fail_if_exists "${zip_file}" || exit 1

fail_unless_writable_directory "${log_dir}" || exit 1

readonly storescp_out="${log_dir}/${uid}.storescp.out"
fail_if_exists "${storescp_out}" || exit 1

readonly movescu_out="${log_dir}/${uid}.movescu.out"
fail_if_exists "${movescu_out}" || exit 1

readonly dest_dir="${WORK_DIR}/archive.${uid}."`timestamp`
mknewdir "${dest_dir}" || exit 1

"${DCM4CHE5}/bin/storescp" \
    --bind "${RETV_AET}" --directory "${dest_dir}" \
    --accept-unknown \
    > "${storescp_out}" &

readonly storescp_pid=$!

readonly rcvaet=`echo "${RETV_AET}" | sed --posix 's:@.*$::'`

"${DCM4CHE5}/bin/movescu" \
    --connect "${SEND_AET}" --bind "${RETV_AET}" --dest "${rcvaet}" \
    -m 0020000D="${uid}" \
    > "${movescu_out}"

readonly movescu_exitcode=$?

kill -s TERM ${storescp_pid}

wait ${storescp_pid}

test 143 -eq $? || {
    error "${DCM4CHE5}/bin/storescp ... exited not in 143"
    exit 1
}

test 0 -eq ${movescu_exitcode} || {
    error "Failed in ${DCM4CHE5}/bin/movescu ..."
}

readonly file_count=`ls -1 "${dest_dir}" | wc -l`

test ${file_count} -gt 0 && {
    (
	cd "${dest_dir}"

	zip --quiet -0 "${zip_file}" * || {
	    error "Failed in zip --quiet -0 ${zip_file} *"
	    exit 1
	}
    ) || exit 1

    zip --quiet --test "${zip_file}" || {
	error "Failed in zip --quiet --test ${zip_file}"
	exit 1
    }

    rm "${dest_dir}"/* || {
	error "Failed in rm ${dest_dir}/*"
	exit 1
    }
}

rmdir "${dest_dir}" || {
    error "Failed in rmdir ${dest_dir}"
    exit 1
}

# rm "${storescp_out}"
# rm "${movescu_out}"

echo ${file_count}

exit 0
