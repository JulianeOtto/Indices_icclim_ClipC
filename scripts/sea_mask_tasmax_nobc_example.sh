#!/bin/bash
#
#==========================================================================================================================================
# correct variable attributes for tasmax indices - use as an example
#==========================================================================================================================================
#
#C.Photiadou 2016/07/25
# Directories
dir_in= #'enter general directory path'
dir_sc=#'enter directory path for scripts'
## name of routines used for calculation & name of institute
path_ic_inst='icclim-4-2-3_KNMI'
## realization, RCM, domain, & freq of indices (if bias corrected then bcmethod, bcref, bcobs should be included)
path_real_bc='r1i1p1_SMHI-RCA4_v1_EUR-44_yr'
#=====================
# Variables
#=====================
## IFS can be ignored...
IFS=$'\n'
## gcms used in this analysis
gcms=('CCCma-CanESM2' 'CNRM-CM5' 'CSIRO-Mk3-6-0' 'EC-EARTH' 'IPSL-CM5A-MR' 'MIROC5' 'HadGEM2-ES' 'MPI-ESM-LR' 'NorESM1-M' 'GFDL-ESM2M')
## indices used: ice days, summer days, annual mean of maximum temperature
indices=('id' 'su' 'tx')
## experiments
exper=('rcp45' 'rcp85' 'historical')
## time periods for rcp4.5, rcp8.5, historical
time_cov_start=('20060101' '20060101' '19700101')
time_cov_end=('20991231' '20991231' '20051231')

#========================================================================
### Fix issue for EC_EARTH and HadGem but remember to bringit back at the end!
### EC-EARTH has different realization adn HadGEM different end dates
#========================================================================

gcm_ec='EC-EARTH'
gcm_ha='HadGEM2-ES'
## hadgem end dates
had_time_end=('20991130' '20991230' '20051230')


 for k in {0..2}; do
	echo
			echo "Rename EC-EARTH & HadGEM"
			echo ${indices[k]} 

		echo
	for i in {0..2}; do
		echo ${exper[i]} 
		echo 
 
		mv ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ec}_${exper[i]}_r12i1p1_SMHI-RCA4_v1_EUR-44_yr_${time_cov_start[i]}-${time_cov_end[i]}.nc ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ec}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc

		mv ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ha}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${had_time_end[i]}.nc ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ha}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc
	done
done

#=====================================================================================
### After calculateing indices with icclim, sea points are null -> make sea points NAs
#=====================================================================================
for k in {0..2}; do 
		###############
		echo
			echo "Sea Mask"
		echo
			echo ${indices[k]}
		echo
		###############
  for j in {0..9}; do  
		echo              
			echo ${gcms[j]}
		echo
	for i in {0..2}; do
			echo ${exper[i]}

		#make nas the sea!
		cdo div ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc \
		        ${dir_sc}mask_file_clipc.nc \
		        ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc
	
		#add back the rlat rlon because of cdo
		ncks -A -v rlat,rlon,rotated_pole ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc \
										  ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc
	
	 # Here a midstep is needed to rename rlon,rlat-->x,y
        ncrename -v rlat,y ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc
        ncrename -v rlon,x ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc

        # Add attribute to the variable
        ncatted -O -h -a grid_mapping,${ind[k]},c,c,"rotated_pole" ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc
		
		#remove the _sm in the filename
		mv ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}_sm.nc ${dir_in}${indices[k]}_${path_ic_inst}_${gcms[j]}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc
        done
	done 
done

#========================================================================
### Correct filename for EC-EARTH & HadGem!
#========================================================================

for k in {0..2}; do 
	for i in {0..2}; do 
	echo
	echo "Rename back EC-EARTH & HadGEM"
	echo
		echo ${indices[k]}
		echo ${exper[i]}
	echo
		mv ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ec}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ec}_${exper[i]}_r12i1p1_SMHI-RCA4_v1_EUR-44_yr_${time_cov_start[i]}-${time_cov_end[i]}.nc

		mv ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ha}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${time_cov_end[i]}.nc ${dir_in}${indices[k]}_${path_ic_inst}_${gcm_ha}_${exper[i]}_${path_real_bc}_${time_cov_start[i]}-${had_time_end[i]}.nc
	done
done 
