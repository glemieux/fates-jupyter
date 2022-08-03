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

def get_siteTS_pft_scpf(flist,vname,pftlist,numsites,numsc):

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
