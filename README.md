PACS Utilities
--------------

### Requirements

* [DCM4Che](http://dcm4che.org), Version 5
* Java Runtime Environment, 7 or later, required by DCM4Che
* xsltproc

### Environment variables

* `JAVA_HOME`, optional, e.g. `/usr/java/jre1.7.0_55`

### Configuration

* Edit `./base.environments`.
* Make directories LOGS_DIR, WORK_DIR and ARCH_DIR specified in `./base.environments`

### Typical procedures

#### Retrieves DICOMs from the remote storage and saves to ZIP files

* Execute `./list-studies.sh`
* In order to select studies to archive, delete some files *.xml in study-list.(timestamp).tsv in WORK_DIR
* Execute `./archive-studies.sh`, giving ZIP files in ARCH_DIR
* Check archive-studies.(timestamp).(study list timestamp).summary.log in LOGS_DIR
* If needed, check the followings in archive-studies.(timestamp).(study list timestamp) in LOGS_DIR
  * (study instance UID).err
  * (study instance UID).storescp.out
  * (study instance UID).movescu.out

### Troubleshooting

#### DCM4Che

* `Exception in thread "main" java.lang.UnsupportedClassVersionError: org/dcm4che3/... : Unsupported major.minor version 51.0`
  * See https://qiita.com/seratch@github/items/731b69d3edabe9c8bc0d and (un)set `JAVA_HOME`
