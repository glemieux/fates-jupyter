#!/bin/bash

#===============================================================================
# CTSM create_newcase template
#===============================================================================

#------------------------------------
# RUN SPECIFIC SETUP - USER TO MODIFY
#------------------------------------
# Set a descriptive name for the case to be run
export DESCNAME=fates_main_api-100_year

# Set debugging option on or off
export DEBUGGING=FALSE

# Set the desired compset - use query_config and/or query_testlist for compset names
export COMPSET=I2000Clm50FatesCruGs

# Set the resolution
export RESOLUTION=f10_f10_mg37

# SET NUMBER OF TASKS
export NUMTASKS=-4

#------------------------------------------------------
# USER AND MACHINE SPECIFIC SETUP - CHANGE AS NECESSARY
#------------------------------------------------------
export PROJECT=P93300641
export CATEGORY=fates
export MACH=cheyenne
export COMPILER=intel
export CASEDIR=/glade/scratch/glemieux/clmed-tests

#---------------------------------------------------------
# SETUP DIRECTORY - USER SHOULD NOT NEED TO CHANGE THESE
#---------------------------------------------------------
# Setup githash to append to test directory name
export CLMHASH=`cd ../../;git log -n 1 --format=%h`
export FATESHASH=`(cd ../../src/fates;git log -n 1 --format=%h)`
export GITHASH="C"${CLMHASH}"-F"${FATESHASH}

# Setup build, run and output directory
export CASENAME=${CASEDIR}/${DESCNAME}.${CATEGORY}.${MACH}.${GITHASH}

#----------------
# CREATE THE CASE
#----------------
./create_newcase --case=${CASENAME} --project=${PROJECT} --res=${RESOLUTION} --compset=${COMPSET} --mach=${MACH} --compiler=${COMPILER} --run-unsupported

# Change to the created case directory
cd ${CASENAME}

#--------------------------------------------------------
# UPDATE CASE CONFIGURATION - USER TO UPDATE AS NECESSARY
#--------------------------------------------------------
# Change the debugging setup
./xmlchange DEBUG=${DEBUGGING}

# Change the output root where CASENAME/bld and CASENAME/run directories will be placed
./xmlchange CIME_OUTPUT_ROOT=${CASEDIR}

# Change the output dir for short term archives (i.e. the run logs)
./xmlchange DOUT_S_ROOT=${CASENAME}/run

# SPECIFY PE LAYOUT FOR SINGLE SITE RUN (USERS WILL PROB NOT CHANGE THESE)
./xmlchange NTASKS_ATM=-1
./xmlchange NTASKS_CPL=${NUMTASKS}
./xmlchange NTASKS_GLC=${NUMTASKS}
./xmlchange NTASKS_OCN=${NUMTASKS}
./xmlchange NTASKS_WAV=${NUMTASKS}
./xmlchange NTASKS_ICE=${NUMTASKS}
./xmlchange NTASKS_LND=${NUMTASKS}
./xmlchange NTASKS_ROF=${NUMTASKS}
./xmlchange NTASKS_ESP=${NUMTASKS}
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_CPL=-1
./xmlchange ROOTPE_GLC=-1
./xmlchange ROOTPE_OCN=-1
./xmlchange ROOTPE_WAV=-1
./xmlchange ROOTPE_ICE=-1
./xmlchange ROOTPE_LND=-1
./xmlchange ROOTPE_ROF=-1
./xmlchange ROOTPE_ESP=-1

# SET TO RUN 10 YEARS AND TO RESUBMIT 10 TIMES
./xmlchange RESUBMIT=10
./xmlchange STOP_N=10
./xmlchange REST_N=1
./xmlchange REST_OPTION=nyears
./xmlchange STOP_OPTION=nyears

./xmlchange CLM_FORCE_COLDSTART=on
./xmlchange JOB_WALLCLOCK_TIME=6:00:00

# CHANGE THE ATMOSPHERIC DRIVER DATASET
./xmlchange DATM_MODE=CLMGSWP3v1

#-------------------------
# SETUP AND BUILD THE CASE
#-------------------------
./case.setup
./case.build

# MANUALLY SUBMIT CASE
echo "To submit the case change directory to ${CASENAME} and run ./case.submit"
