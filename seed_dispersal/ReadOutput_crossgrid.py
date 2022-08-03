#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 19 21:22:27 2022

@author: liu.9367
"""


import numpy as np
import pandas as pd
from glob import glob
import matplotlib.pyplot as plt
import seaborn as sns; sns.set(style="ticks", color_codes=True,font_scale=1.5)
import netCDF4 as nc
# from Utilities import ncdump

def getTS(flist,vnamelist):
    TS = [[] for fname in vnamelist]
    for fid,fname in enumerate(flist):
        nc_fid = nc.Dataset(fname,'r')
        # print("getTS: fname: {}".format(fname))
        for i,vname in enumerate(vnamelist):
            # print("getTS: i: {}, vname: {}".format(i,vname))
            TS[i].append(nc_fid.variables[vname][:].data.flatten())
    return np.array(TS)[0]

def get_siteTS_pft(flist,vname,pftlist,numsites):

    VAR = getTS(flist,[vname])
    # print("getsiteTSpft: VAR: {}".format(VAR))
    SS = [np.zeros([len(VAR),len(pftlist)]) for i in range(numsites)]
    for s in range(numsites):
        # print("getsiteTSpft: s: {}".format(s))
        for i,pft in enumerate(pftlist):
            # print("getsiteTSpft: i: {}, pft: {}".format(i,pft))
            SS[s][:,i] = VAR[:,pft*numsites+s]
    return SS

def get_siteTS_pft_scpf(flist,vname,pftlist,numsites):

    VAR = getTS(flist,[vname])
    SS = [np.zeros([len(VAR),len(pftlist)]) for i in range(numsites)]
    for s in range(numsites):
        for i,pft in enumerate(pftlist):
            SS[s][:,i] = VAR[:,pft*numsites*numsc+s] # assumming all in the smallest size class
    return SS


def get_siteTS_all(flist,vname,numsites):

    VAR = getTS(flist,[vname])
    SS = [np.zeros([len(VAR),]) for i in range(numsites)]
    for s in range(numsites):
        SS[s][:] = VAR[:,s]
    return SS

#%%
"""
Target variables: 
    FATES_VEGC_PF, units='gC/m2', 'total PFT level biomass'
    FATES_SEEDS_IN_LOCAL_EL, units='kg ha-1 d-1','Within Site Seed Production Rate'
    FATES_SEEDS_IN_EXTERN_EL, units='kg ha-1 d-1', 'External Seed Influx Rate'
"""
# inpath_off = '/Users/yanlan/Data/NGEE/FATES/CrossGrid/Runs/control/'; tag_off = 'cross-grid dispersal off'
# inpath_on = '/Users/yanlan/Data/NGEE/FATES/CrossGrid/Runs/koug_seed2_3pft/'; tag_on = 'cross-grid dispersal on'
inpath_off = '/home/glemieux/scratch/e3sm-cases/cross_grid_glemieux-koug-base.fates.lobata.E8201c02fa6-F4772c523/run/lnd/'; tag_off = 'cross-grid dispersal off'
inpath_on = '/home/glemieux/scratch/e3sm-cases/cross_grid_glemieux-koug.fates.lobata.E9f562b53ab-F8b0ed78c/run/lnd/'; tag_on = 'cross-grid dispersal on'


numsites = 2
numsc = 13
numpft = 12
pftlist = [6,8,9]
# pftlist = [1,2,3]
pftname = ['Evergreen Shrub','Deciduous Shrub','Arctic C3 Grass']
pftcolor=['g','gold','b']
flist = glob(inpath_off+'*.nc'); flist.sort()
# flist = flist[1:12*15]
# flist = flist[1:12*15]

FATES_VEGC_PF_off = get_siteTS_pft(flist,'FATES_VEGC_PF',pftlist,numsites)
SEEDS_IN_LOCAL_off = get_siteTS_all(flist,'FATES_SEEDS_IN_LOCAL_EL',numsites)
SEEDS_IN_EXTERN_off = get_siteTS_all(flist,'FATES_SEEDS_IN_EXTERN_EL',numsites)
# SEEDS_IN_EXTERN_off[0] = SEEDS_IN_EXTERN_off[0]
# SEEDS_IN_EXTERN_off[1] = SEEDS_IN_EXTERN_off[1]
NPP_SEED_off = get_siteTS_pft_scpf(flist,'FATES_SEED_ALLOC_SZPF',pftlist,numsites)

#%%
flist = glob(inpath_on+'*.nc'); flist.sort()
# flist = flist[1:12*15]
# flist = flist[1:]
FATES_VEGC_PF_on = get_siteTS_pft(flist,'FATES_VEGC_PF',pftlist,numsites)
SEEDS_IN_LOCAL_on = get_siteTS_all(flist,'FATES_SEEDS_IN_LOCAL_EL',numsites)
SEEDS_IN_EXTERN_on = get_siteTS_all(flist,'FATES_SEEDS_IN_EXTERN_EL',numsites)
# SEEDS_IN_EXTERN_on[0] = SEEDS_IN_EXTERN_on[0]
# SEEDS_IN_EXTERN_on[1] = SEEDS_IN_EXTERN_on[1]
NPP_SEED_on = get_siteTS_pft_scpf(flist,'FATES_SEED_ALLOC_SZPF',pftlist,numsites)

#%% Plot FATES_VEGC_PF
# ylim = [-1,900]
ylim = [-0.005,0.015]
ylim_seed = [0,120]
plt.figure(figsize=(10,5))
plt.subplot(121)
for ipft in range(len(pftlist)):
    plt.plot(FATES_VEGC_PF_off[0][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
plt.xlabel('Month')
plt.ylabel('FATES_VEGC_PF (gC/m2)')
plt.legend(loc=2)
plt.ylim(ylim)
plt.title('Grid 1, '+tag_off)

plt.subplot(122)
for ipft in range(len(pftlist)):
    plt.plot(FATES_VEGC_PF_off[1][:,ipft],c=pftcolor[ipft])
plt.xlabel('Month')
plt.ylim(ylim)
plt.title('Grid 2, '+tag_off)

#%%
# ylim = [-1,900]
ylim_seed = [0,120]
plt.figure(figsize=(10,5))
plt.subplot(121)
for ipft in range(len(pftlist)):
    plt.plot(FATES_VEGC_PF_on[0][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
plt.xlabel('Month')
plt.ylabel('FATES_VEGC_PF (gC/m2)')
plt.legend(loc=2)
plt.ylim(ylim)
plt.title('Grid 1, '+tag_on)

plt.subplot(122)
for ipft in range(len(pftlist)):
    plt.plot(FATES_VEGC_PF_on[1][:,ipft],c=pftcolor[ipft])
plt.xlabel('Month')
plt.ylim(ylim)
plt.title('Grid 2, '+tag_on)


#%%
# ylim = [-1,900]
ylim_seed = [0,120]
plt.figure(figsize=(10,5))
plt.subplot(121)
for ipft in range(len(pftlist)):
    plt.plot(FATES_VEGC_PF_on[0][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
    plt.plot(FATES_VEGC_PF_off[0][:,ipft],'--',c=pftcolor[ipft])
plt.xlabel('Month')
plt.ylabel('FATES_VEGC_PF (gC/m2)')
plt.legend(loc=2)
plt.ylim(ylim)
plt.title('Grid 1')

plt.subplot(122)
for ipft in range(1):#range(len(pftlist)):
    # plt.plot(FATES_VEGC_PF_on[1][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
    # plt.plot(FATES_VEGC_PF_off[1][:,ipft],'--',c=pftcolor[ipft])
    plt.plot(FATES_VEGC_PF_on[1][:,ipft],c='k',label='Dispersal on')
    plt.plot(FATES_VEGC_PF_off[1][:,ipft],'--k',label='Dispersal off')
plt.legend()
plt.xlabel('Month')
plt.ylim(ylim)
plt.title('Grid 2')


#%% Plot FATES_VEGC_PF
# ylim = [-0.1,2.2]
# ylim = [-0.1,3.2]

ylim_seed = [0,100]
plt.figure(figsize=(10,5))
plt.subplot(121)
for ipft in range(len(pftlist)):
    plt.plot(NPP_SEED_off[0][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
plt.xlabel('Month')
plt.ylabel('NPP_SEED (kgC/m2/yr)')
plt.ylim(ylim)
plt.title('Grid 1, '+tag_off)

plt.subplot(122)
for ipft in range(len(pftlist)):
    plt.plot(NPP_SEED_off[1][:,ipft],c=pftcolor[ipft],label=pftname[ipft])
plt.xlabel('Month')
plt.ylim(ylim)
plt.title('Grid 2, '+tag_off)
plt.legend(loc=1)



#%% 
# ylim = [-5,330]
# ylim = [-5,1000]
plt.figure(figsize=(10,5))
plt.subplot(121)
plt.plot(FATES_VEGC_PF_off[0][:,1],label='dispersal off')
plt.plot(FATES_VEGC_PF_on[0][:,1],label='dispersal on')
plt.legend()
plt.xlabel('Month')
plt.ylabel('Decid. shrub biomass (gC/m2)')
plt.title('Grid 1')
plt.ylim(ylim)

plt.subplot(122)
plt.plot(FATES_VEGC_PF_off[1][:,1],label='dispersal off')
plt.plot(FATES_VEGC_PF_on[1][:,1],label='dispersal on')
plt.legend()
plt.xlabel('Month')
# plt.ylabel('FATES_VEGC_PF (gC/m2)')
plt.title('Grid 2')
plt.ylim(ylim)


#%%
plt.figure()
plt.plot(SEEDS_IN_LOCAL_off[0],label='Grid1')
plt.plot(SEEDS_IN_LOCAL_off[1],label='Grid2')
plt.legend()
plt.xlabel('Month')
plt.ylabel('SEEDS_IN_LOCAL (kg/ha/d)')
plt.title(tag_off)
plt.ylim(ylim_seed)

#%%
plt.figure()
plt.plot(SEEDS_IN_EXTERN_off[0]/2,label='Grid1')
plt.plot(SEEDS_IN_EXTERN_off[1]/2,label='Grid2')
plt.legend()
plt.xlabel('Month')
plt.ylabel('SEEDS_IN_EXTERN (kg/ha/d)')
plt.title(tag_off)
plt.ylim(ylim_seed)


#%%
plt.figure(figsize=(10,5))
plt.subplot(121)
plt.plot(SEEDS_IN_LOCAL_off[0],label='dispersal off')
plt.plot(SEEDS_IN_LOCAL_on[0],label='dispersal on')
plt.legend()
plt.xlabel('Month')
plt.ylabel('Local seed (kg/ha/d)')
plt.title('Grid 1')
plt.ylim(ylim_seed)

plt.subplot(122)

plt.plot(SEEDS_IN_LOCAL_off[1],label='dispersal off')
plt.plot(SEEDS_IN_LOCAL_on[1],label='dispersal on')
plt.legend()
plt.xlabel('Month')
# plt.ylabel('SEEDS_IN_LOCAL (kg/ha/d)')
plt.title('Grid 2')
plt.ylim(ylim_seed)

#%%
plt.figure(figsize=(10,5))
plt.subplot(121)
plt.plot(SEEDS_IN_EXTERN_off[0],label='dispersal off')
plt.plot(SEEDS_IN_EXTERN_on[0],label='dispersal on')
plt.legend()
plt.xlabel('Month')
plt.ylabel('External seed (kg/ha/d)')
plt.title('Grid 1')
plt.ylim(ylim_seed)

plt.subplot(122)

plt.plot(SEEDS_IN_EXTERN_off[1],label='dispersal off')
plt.plot(SEEDS_IN_EXTERN_on[1],label='dispersal on')
plt.legend()
plt.xlabel('Month')
# plt.ylabel('SEEDS_IN_LOCAL (kg/ha/d)')
plt.title('Grid 2')
plt.ylim(ylim_seed)

#%%
ylim=[-5,68]
plt.figure(figsize=(5,5))
tmp = SEEDS_IN_EXTERN_on[1][1:]-SEEDS_IN_LOCAL_on[0][:-1]/0.8*0.2
SEEDS_IN_EXTERN_on[1][1:][tmp>2] = np.nan
plt.plot(SEEDS_IN_EXTERN_on[1][1:],SEEDS_IN_LOCAL_on[0][:-1]/0.8*0.2,'o',label='Grid 1')
plt.plot(SEEDS_IN_EXTERN_on[0][1:],SEEDS_IN_LOCAL_on[1][:-1]/0.8*0.2,'^',label='Grid 2')

# plt.plot(SEEDS_IN_EXTERN_on[1][1:]/(SEEDS_IN_LOCAL_on[0][:-1]/0.8*0.2),'ok')
plt.plot([0,18],[0,18],'--k')
# plt.plot(ylim,ylim,'--k')]
# plt.xlabel('Month')
plt.xlabel('External seed (kg/ha/d)')
plt.ylabel('Expected external seed (kg/ha/d)')
plt.legend()
# plt.xlim([0,24])
# plt.xlim(ylim);plt.ylim(ylim)

#%%
plt.figure(figsize=(5,5))
plt.plot(NPP_SEED_on[0][:,1][:-1],SEEDS_IN_EXTERN_on[1][1:],'ok')

plt.xlabel('Grid 1, NPP for seed (kgC/m2/yr)')
plt.ylabel('Grid 2, External seed (kg/ha/d)')



#%%
# plt.plot(SEEDS_IN_LOCAL_on[0][:-1]/0.8*0.2,SEEDS_IN_EXTERN_on[1][1:],'ok')
plt.hist(SEEDS_IN_EXTERN_on[1][1:]/(SEEDS_IN_LOCAL_on[0][:-1]/0.8*0.2))
# plt.xlim(ylim);plt.ylim(ylim)


# plt.plot(SEEDS_IN_EXTERN_on[0][1:], NPP_SEED_on[1][:,1][:-1],'ok')


# NPP_SEED_off[1][:,ipft]

plt.show()

