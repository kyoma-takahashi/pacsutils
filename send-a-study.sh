#!/bin/sh

. $( dirname "${0}" )/common.sh

src_zip="$1"
log_dir="$2"

if test -r "${src_zip}"
then
    :
else
    echo "[Error] File ${src_zip}, given as the first argument, has to be read." >&2
    exit 1
fi

if test -e "${log_dir}" -a -d "${log_dir}" -a -w "${log_dir}"
then
    :
else
    echo "[Error] Directory ${log_dir} has to exist, and to be written." >&2
    exit 1
fi

zip --quiet --test "${src_zip}" || {
    echo "Failed in zip --test ${src_zip}" >&2
    exit 1
}

src_zip_bn=$( basename "${src_zip}" | sed 's|\.zip||i' )

unzipped_dir="${WORK_DIR}/to-send.${src_zip_bn}".$( timestamp )

if test -e "${unzipped_dir}"
then
    echo "[Error] Already exists: ${unzipped_dir}" >&2
    exit 1
fi

unzip -qq "${src_zip}" -d "${unzipped_dir}"

if [ $? -ne 0 ]
then
    echo "[Error] Failed in unzip -qq ${src_zip} -d ${unzipped_dir}" >&2
    exit 1
fi

if test -e "${unzipped_dir}"
then
    :
else
    echo "[Error] Not exists: ${unzipped_dir}" >&2
    exit 1
fi

storescu_out="${log_dir}/${src_zip_bn}."$( timestamp )'.storescu.out'

if test -e "${storescu_out}"
then
    echo "[Error] Already exists: ${storescu_out}" >&2
    exit 1
fi

"${DCM4CHE5}/bin/storescu" \
    --bind "${CALLING_AET}" --connect "${CALLED_AET}" \
    "${unzipped_dir}" \
    > "${storescu_out}"

if [ $? -ne 0 ]
then
    echo "[Error] Failed in ${DCM4CHE5}/bin/storescu ... ${unzipped_dir}" >&2
    exit 1
fi

rm -r "${unzipped_dir}"

if [ $? -ne 0 ]
then
    echo "[Error] Failed in rm -r ${unzipped_dir}" >&2
    exit 1
fi

exit 0
