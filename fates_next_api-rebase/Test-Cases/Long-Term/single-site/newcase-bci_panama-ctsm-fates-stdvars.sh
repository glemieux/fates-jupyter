#!/bin/sh
# =======================================================================================
#
# This script will create, setup and build a single-site simulation at 
# Barro Colorado Island, Panama
#
# A specialized domain and surface file was generated using Gautam Bisht's
# "matlab-script-for-clm-sparse-grid".
#
# Meteorological driving data was prepared using Ryan Knox's "ConvertMetCSVtoCLM".
# PLEASE SEE THE DRIVER DATA'S METADATA FOR ACKNOWLEDGMENTS AND ATTRIBUTION
#
# In this implementation, meteorological data will be cycled based on the data
# offsets.  We make use of "CLM1PT" datm mode, and make a minor modification to the
# default stream-file to signal to CLM/ELM that no downwelling long-wave is available
# in our dataset.
#
# The base-version of this script, works off the assumption that driver data
# and surface/domain data have been unpacked in the cime/scripts directory
# and can all be found in a parent directory with alias $SITE_DIR
#
#
# Ryan Knox (Mon Nov 13 13:53:03 PST 2017)
# Updated to 14 year BCI record Nov 14
#
# USER SETTINGS
# USER MAY ALSO WANT TO ADJUST XML CHANGES, AND NAMELIST ARGUMENTS
# =======================================================================================
export CIME_MODEL=cesm
export SITE_NAME=bci_0.1x0.1_v4.0i                             # Name of folder with site data
export SITE_BASE_DIR=/data/sitedata                            # Where is the site folder located? (SITE_NAME)
export TAG='fna-rebase-2-hlm_harvest'             # User defined tag to differentiate runs
export COMPSET=2000_DATM%CRUv7_CLM50%FATES_SICE_SOCN_SROF_SGLC_SWAV #I2000Clm50FatesGs                               # Compset (probably ICLM45ED or ICLM50ED)
export MACH=lobata                                             # Name your machine
export COMPILER=gnu                                            # Name your compiler
export CASEROOT=/home/glemieux/scratch/clmed-cases             # Where the build is generated (probably on scratch partition)
export CLM_USRDAT_DOMAIN=domain_bci_clm5.0.dev009_c180523.nc   # Name of domain file in data/${SITE_DIR}/
export CLM_USRDAT_SURDAT=surfdata_bci_clm5.0.dev009_c180523.nc # Name of surface file in data/${SITE_DIR}/
export PROJECT=WAREBEAR
#export FATES_PARAM_FILE_PATH=/home/glemieux/parameter_files
#export FATES_PARAM_FILE=fates_params_api.8.1.0-1pft-leafflutter-2020_02_06.nc
#export FATES_PARAM_FILE=fates_params_api.8.1.0-1pft-leafflutter-2020_04_02-deciduous.nc

# DEPENDENT PATHS AND VARIABLES (USER MIGHT CHANGE THESE..)
# =======================================================================================

export CLM_SURFDAT_DIR=${SITE_BASE_DIR}/${SITE_NAME}
export CLM_DOMAIN_DIR=${SITE_BASE_DIR}/${SITE_NAME}
export DIN_LOC_ROOT_FORCE=${SITE_BASE_DIR}           # Is this point to the correct location? (GL)
export CLM_HASH=`cd ../../;git log -n 1 --format=%h`
export FATES_HASH=`(cd ../../src/fates;git log -n 1 --pretty=%h)`
export GIT_HASH=C${CLM_HASH}-F${FATES_HASH}
export RES=CLM_USRDAT
export CASE_NAME=${CASEROOT}/${TAG}.${GIT_HASH}.`date +"%Y-%m-%d"`

# export USRDAT_METFORCE_NAME=${SITE_DIR} (DEPRECATED?)


# REMOVE EXISTING CASE IF PRESENT
rm -r ${CASE_NAME}

# CREATE THE CASE
./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --compiler=${COMPILER} --run-unsupported


cd ${CASE_NAME}


# SET PATHS TO SCRATCH ROOT, DOMAIN AND MET DATA (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================

./xmlchange ATM_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
./xmlchange ATM_DOMAIN_PATH=${CLM_DOMAIN_DIR}
./xmlchange LND_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
./xmlchange LND_DOMAIN_PATH=${CLM_DOMAIN_DIR}
./xmlchange DATM_MODE=CLM1PT
./xmlchange CLM_USRDAT_NAME=${SITE_NAME}
./xmlchange DIN_LOC_ROOT_CLMFORC=${DIN_LOC_ROOT_FORCE}
./xmlchange CIME_OUTPUT_ROOT=${CASE_NAME}

# SPECIFY PE LAYOUT FOR SINGLE SITE RUN (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================

# ./xmlchange NTASKS_ATM=1
# ./xmlchange NTASKS_CPL=1
# ./xmlchange NTASKS_GLC=1
# ./xmlchange NTASKS_OCN=1
# ./xmlchange NTASKS_WAV=1
# ./xmlchange NTASKS_ICE=1
# ./xmlchange NTASKS_LND=1
# ./xmlchange NTASKS_ROF=1
# ./xmlchange NTASKS_ESP=1
# ./xmlchange ROOTPE_ATM=0
# ./xmlchange ROOTPE_CPL=0
# ./xmlchange ROOTPE_GLC=0
# ./xmlchange ROOTPE_OCN=0
# ./xmlchange ROOTPE_WAV=0
# ./xmlchange ROOTPE_ICE=0
# ./xmlchange ROOTPE_LND=0
# ./xmlchange ROOTPE_ROF=0
# ./xmlchange ROOTPE_ESP=0
# ./xmlchange NTHRDS_ATM=1
# ./xmlchange NTHRDS_CPL=1
# ./xmlchange NTHRDS_GLC=1
# ./xmlchange NTHRDS_OCN=1
# ./xmlchange NTHRDS_WAV=1
# ./xmlchange NTHRDS_ICE=1
# ./xmlchange NTHRDS_LND=1
# ./xmlchange NTHRDS_ROF=1
# ./xmlchange NTHRDS_ESP=1

# SPECIFY RUN TYPE PREFERENCES (USERS WILL CHANGE THESE)
# =================================================================================

./xmlchange DEBUG=FALSE
./xmlchange STOP_N=100
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=5
./xmlchange DATM_CLMNCEP_YR_START=2003
./xmlchange DATM_CLMNCEP_YR_END=2016
./xmlchange RUN_STARTDATE='1900-01-01'


# MACHINE SPECIFIC, AND/OR USER PREFERENCE CHANGES (USERS WILL CHANGE THESE)
# =================================================================================

./xmlchange GMAKE=make
./xmlchange DOUT_S_SAVE_INTERIM_RESTART_FILES=TRUE
./xmlchange DOUT_S=TRUE
./xmlchange DOUT_S_ROOT='$CASEROOT/run'
./xmlchange RUNDIR=${CASE_NAME}/run
./xmlchange EXEROOT=${CASE_NAME}/bld

# Copy in the parameter file
#cp ${FATES_PARAM_FILE_PATH}/${FATES_PARAM_FILE} .

# MODIFY THE CLM NAMELIST (USERS MODIFY AS NEEDED)
#cat >> user_nl_clm <<EOF
#fates_paramfile = "`pwd`/${FATES_PARAM_FILE}"
#fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
#EOF

cat >> user_nl_clm <<EOF
fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
EOF
#hist_empty_htapes = .true.
#hist_fincl1='TLAI','ELAI','TSAI','ESAI','NET_C_UPTAKE_CNLF',
#'TRIMMING','LAI_CANOPY_SCLS','SAI_CANOPY_SCLS','TRIMMING_CANOPY_SCLS','TRIMMING_UNDERSTORY_SCLS',
#'LAISUN_Z_CNLF','LAISHA_Z_CNLF','LAISUN_TOP_CAN','LAISHA_TOP_CAN','CROWNAREA_CNLF',
#'NPLANT_SCAG','NPLANT_CANOPY_SCAG','NPLANT_UNDERSTORY_SCAG',
#'NPLANT_SCLS','NPLANT_CANOPY_SCLS','NPLANT_UNDERSTORY_SCLS',
#'CANOPY_HEIGHT_DIST',
#'GPP_SCPF','GPP_CANOPY_SCPF','GPP_UNDERSTORY_SCPF'
#EOF

# cat >> user_nl_clm <<EOF
# fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
# hist_fincl1='NEP','NPP','GPP','TLAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR','HR','ED_biomass','FSDS',
# 'ED_bleaf','ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF','M3_SCPF','M4_SCPF',
# 'M5_SCPF','M6_SCPF','M7_SCPF','M8_SCPF','M9_SCPF','RECRUITMENT','RH','TBOT','PBOT','QBOT','RAIN','FLDS'
# use_fates_ed_prescribed_phys = .true.
#EOF

# Usefull user_nl_clm arguments: 
# use_fates_inventory_init = .true.
# fates_inventory_ctrl_filename = '${SITE_BASE_DIR}/${SITE_NAME}/bci_inv_file_list.txt'
# This couplet will enable hourly output
# hist_mfilt             = 480      
# hist_nhtfrq            = -1  
# hist_fincl1='NEP','NPP','GPP','TLAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR','HR','ED_biomass','ED_bleaf',
#'ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF','M3_SCPF','M4_SCPF','M5_SCPF','M6_SCPF',
#'WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT','RAIN','FLDS'
#,'FATES_ERRH2O_SCPF','FATES_TRAN_SCPF','FATES_ROOTUPTAKE_SCPF',
#'FATES_ROOTUPTAKE01_SCPF','FATES_ROOTUPTAKE02_SCPF','FATES_ROOTUPTAKE10_SCPF','FATES_SAPFLOW_COL_SCPF',
#'FATES_ITERH1_COL_SCPF','FATES_ITERH2_COL_SCPF','FATES_ATH_COL_SCPF','FATES_TTH_COL_SCPF',
#'FATES_STH_COL_SCPF','FATES_LTH_COL_SCPF','FATES_BTRAN_COL_SCPF'

# MODIFY THE DATM NAMELIST (DANGER ZONE - USERS BEWARE CHANGING)

cat >> user_nl_datm <<EOF
taxmode = "cycle", "cycle", "cycle"
EOF

./case.setup

# NEED TO MODIFY THE STREAM FILE (DANGER ZONE - USERS BEWARE CHANGING)
./preview_namelists
cp run/datm.streams.txt.CLM1PT.CLM_USRDAT user_datm.streams.txt.CLM1PT.CLM_USRDAT
`sed -i '/FLDS/d' user_datm.streams.txt.CLM1PT.CLM_USRDAT`

./case.build
