#!/bin/sh

readonly local_dir=`dirname "${0}"`

. "${local_dir}/common.sh"

readonly src_zip="$1"
readonly log_dir="$2"

test -r "${src_zip}" || {
    error "File ${src_zip}, given as the first argument, has to be read."
    exit 1
}

fail_unless_writable_directory "${log_dir}" || exit 1

zip --quiet --test "${src_zip}" || {
    error "Failed in zip --test ${src_zip}"
    exit 1
}

readonly src_zip_bn=`basename "${src_zip}" | sed 's|\.zip||i'`

readonly unzipped_dir="${WORK_DIR}/to-send.${src_zip_bn}".`timestamp`
fail_if_exists "${unzipped_dir}" || exit 1

unzip -qq "${src_zip}" -d "${unzipped_dir}" || {
    error "Failed in unzip -qq ${src_zip} -d ${unzipped_dir}"
    exit 1
}

test -e "${unzipped_dir}" || {
    error "Not exists: ${unzipped_dir}"
    exit 1
}

readonly storescu_out="${log_dir}/${src_zip_bn}."`timestamp`'.storescu.out'
fail_if_exists "${storescu_out}" || exit 1

"${DCM4CHE5}/bin/storescu" \
    --bind "${CALLING_AET}" --connect "${CALLED_AET}" \
    "${unzipped_dir}" \
    > "${storescu_out}" || {
	error "Failed in ${DCM4CHE5}/bin/storescu ... ${unzipped_dir}"
	exit 1
    }

rm -r "${unzipped_dir}" || {
    error "Failed in rm -r ${unzipped_dir}"
    exit 1
}

exit 0
