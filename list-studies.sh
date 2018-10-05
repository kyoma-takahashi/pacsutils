#!/bin/sh

local_dir=$( dirname "${0}" )

. "${local_dir}/common.sh"

study_list_dir="${WORK_DIR}/study-list."$( timestamp )

study_list_file="${study_list_dir}.tsv"

if test -e "${study_list_file}"
then
    echo "[Error] Already exists: ${study_list_file}" >&2
    exit 1
fi

if test -e "${study_list_dir}"
then
    echo "[Error] Already exists: ${study_list_dir}" >&2
    exit 1
fi

mkdir "${study_list_dir}"
if [ $? -ne 0 ]
then
    echo "[Error] Failed in mkdir ${study_list_dir}" >&2
    exit 1
fi

"${DCM4CHE5}/bin/findscu" \
    --bind "${RETV_AET}" --connect "${SEND_AET}" \
    -L STUDY \
    -r PatientName -r PatientID -r StudyDate -r StudyTime -r StudyInstanceUID -r NumberOfStudyRelatedInstances \
    --xml --indent \
    --out-dir "${study_list_dir}" \
    --out-file 0.xml \
    > /dev/null

# Do not give --xmlns
# Otherwise, the xml cannnot be processed by xsltproc study.csv.xsl

# Do not give
# -r AccessionNumber -r ModalitiesInStudy -r ReferringPhysicianName -r IssuerOfPatientID -r PatientBirthDate -r PatientSex -r StudyID -r NumberOfStudyRelatedSeries
# Otherwise, some field(s) are not output.

if [ $? -ne 0 ]
then
    echo "[Error] Failed in ${DCM4CHE5}/bin/findscu ... --out-dir ${study_list_dir}" >&2
    exit 1
fi

{
    ls -1 "${study_list_dir}" | while read study_xml
    do
	xsltproc "${local_dir}/study.tsv.xsl" "${study_list_dir}/${study_xml}"
	if [ $? -ne 0 ]
	then
	    echo "[Error] Failed in xsltproc study.tsv.xsl ${study_list_dir}/${study_xml}" >&2
	    exit 1
	fi
	rm "${study_list_dir}/${study_xml}" \
	    || echo "[Warning] Failed in rm ${study_list_dir}/${study_xml}" >&2
    done
} > "${study_list_file}"

rmdir "${study_list_dir}" \
    || echo "[Warning] Failed in rmdir ${study_list_dir}" >&2

echo "${study_list_file}"

exit 0
