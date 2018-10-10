#!/bin/sh

readonly local_dir=`dirname "${0}"`

. "${local_dir}/common.sh"

command -v xsltproc > /dev/null || {
    error 'Not found: xsltproc'
    exit 1
}

readonly study_list_dir="${WORK_DIR}/study-list."`timestamp`
mknewdir "${study_list_dir}" || exit 1

readonly study_list_file="${study_list_dir}.tsv"
fail_if_exists "${study_list_file}" || exit 1

"${DCM4CHE5}/bin/findscu" \
    --bind "${RETV_AET}" --connect "${SEND_AET}" \
    -L STUDY \
    -r PatientName -r PatientID -r StudyDate -r StudyTime -r StudyInstanceUID -r NumberOfStudyRelatedInstances \
    --xml --indent \
    --out-dir "${study_list_dir}" \
    --out-file 0.xml \
    > /dev/null || {
	error "Failed in ${DCM4CHE5}/bin/findscu ... --out-dir ${study_list_dir}"
	exit 1
    }

# Do not give --xmlns
# Otherwise, the xml cannnot be processed by xsltproc study.csv.xsl

# Do not give
# -r AccessionNumber -r ModalitiesInStudy -r ReferringPhysicianName -r IssuerOfPatientID -r PatientBirthDate -r PatientSex -r StudyID -r NumberOfStudyRelatedSeries
# Otherwise, some field(s) are not output.

{
    ls -1 "${study_list_dir}" | while read study_xml
    do
	xsltproc "${local_dir}/study.tsv.xsl" "${study_list_dir}/${study_xml}" || {
	    error "Failed in xsltproc study.tsv.xsl ${study_list_dir}/${study_xml}"
	    exit 1
	}

	rm "${study_list_dir}/${study_xml}" \
	    || error "Failed in rm ${study_list_dir}/${study_xml}"
    done
} > "${study_list_file}"

rmdir "${study_list_dir}" \
    || error "Failed in rmdir ${study_list_dir}"

echo "${study_list_file}"

exit 0
