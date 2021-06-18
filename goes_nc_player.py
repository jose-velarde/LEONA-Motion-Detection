# PROJ Installation
# cd Download either the 32 bit or 64 bit installer.
# Run the OSGeo4W setup program.
# Select “Advanced Install” and press Next.
# Select “Install from Internet” and press Next.
# Select a installation directory. The default suggestion is fine in most cases. Press Next.
# Select “Local package directory”. The default suggestion is fine in most cases. Press Next.
# Select “Direct connection” and press Next.
# Choose the download.osgeo.org server and press Next.
# Find “proj” under “Commandline_Utilities” and click the package in the “New” column until the version you want to install appears.
# Press next to install PROJ.
##
# pip install  matplotlib
# pip install  numpy
# pip install  pyproj
# pip install  pyshp
# pip install six
##
# Download from https://www.lfd.uci.edu/~gohlke/pythonlibs/
# pip install basemap-1.2.2-cp38-cp38-win_amd64.whl

#######################################################################################################
# GNC-A Blog Python Script Example to Manipulate GOES-16 NetCDF's Provided By INPE Via FTP
#######################################################################################################
# Required libraries ==================================================================================
from matplotlib import axes
import matplotlib.pyplot as plt # Import the Matplotlib package

import numpy as np # Import the Numpy package

from map_scripts.cpt_convert import loadCPT # Import the CPT convert function
from matplotlib.colors import LinearSegmentedColormap # Linear interpolation for color maps

from matplotlib.patches import Rectangle # Library to draw rectangles on the plot
from netCDF4 import Dataset # Import the NetCDF Python interface

import cartopy
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
# Required libraries ==================================================================================

# Path to the GOES-R simulated image file
path = '201910_nc\\S10635346_201910281600.nc'

# Getting information from the file name ==============================================================
# Search for the GOES-16 channel in the file name
INPE_Band_ID = (path[path.find("S10635")+6:path.rfind("_")])
# Get the band number subtracting the value by 332
Band = int(INPE_Band_ID) - 332
if Band > 10:
	Band = Band -1
# Create a GOES-16 Bands string array
Wavelenghts = ['[]','[0.47 μm]','[0.64 μm]','[0.865 μm]','[1.378 μm]','[1.61 μm]','[2.25 μm]','[3.90 μm]','[6.19 μm]','[6.95 μm]','[7.34 μm]','[8.50 μm]','[9.61 μm]','[10.35 μm]','[11.20 μm]','[12.30 μm]','[13.30 μm]']
Band_Wavelenght = Wavelenghts[int(Band)]
# Search for the Scan start in the file name
Start = (path[path.find(INPE_Band_ID + "_")+4:path.find(".nc")]) 
# Getting the date from the file name
year = Start[0:4]
month = Start[4:6]
day = Start[6:8]
date = day + "-" + month + "-" + year 
time = Start [8:10] + ":" + Start [10:12] + " UTC" # Time of the Start of the Scan
	
# Get the unit based on the channel. If channels 1 trough 6 is Albedo. If channels 7 to 16 is BT.

Unit = "Brightness Temperature [°C]"
# Choose a title for the plot
Title = " GOES-16 ABI CMI Band " + str(Band) + " " + Band_Wavelenght + " " + Unit + " " + date + " " + time 
# Required libraries ==================================================================================

# Open the file using the NetCDF4 library
nc = Dataset(path)

# Choose the visualization extent (min lon, max lon, min lat, max lat)
# extent = [-115.98, -25.01, -55.98, 34.98]
extent = [-80, 0, -55.98, -20]
min_lon = extent[0]
max_lon = extent[1]
min_lat = extent[2]
max_lat = extent[3]

# Get the latitudes
lats = nc.variables['lat'][:] 
# Get the longitudes
lons = nc.variables['lon'][:]

# print (lats)
# print (lons)

# latitude lower and upper index
latli = np.argmin( np.abs( lats - extent[2] ) )
latui = np.argmin( np.abs( lats - extent[3] ) )

# longitude lower and upper index
lonli = np.argmin( np.abs( lons - extent[0] ) )
lonui = np.argmin( np.abs( lons - extent[1] ) )

# Extract the Brightness Temperature values from the NetCDF
data = nc.variables['Band1'][ latli:latui , lonli:lonui ]

# Flip the y axis, divede by 100 and subtract 273.15 to convert to celcius
data = (np.flipud(data) / 100) - 273.15

# Plot the Data =======================================================================================
# Define the size of the saved picture=================================================================
DPI = 200
# ax = plt.figure(figsize=(980/float(DPI), 880/float(DPI)), frameon=True, dpi=DPI)
ax = plt.figure()
#======================================================================================================

# Converts a CPT file to be used in Python
cpt = loadCPT('.\\Colortables\\IR4AVHRR6.cpt') 
# Makes a linear interpolation
cpt_convert = LinearSegmentedColormap('cpt', cpt) 

ax = plt.axes(projection=ccrs.PlateCarree())
img_extent = (extent[0], extent[1], extent[2], extent[3])

shapefile = list(shpreader.Reader(".\\Shapefiles\\BRA_ADM1.shp").geometries())
ax.add_geometries(shapefile, ccrs.PlateCarree(), edgecolor='gold',facecolor='none', linewidth=0.3)

# Add coastlines, borders and gridlines
ax.coastlines(resolution='110m', color='white', linewidth=0.8)
ax.add_feature(cartopy.feature.BORDERS, edgecolor='white', linewidth=0.8)
ax.gridlines(color='white', alpha=0.5, linestyle='--', linewidth=0.5)

# Plot the image
img = ax.imshow(data, vmin=-80, vmax=40, origin='upper', extent=img_extent, cmap=cpt_convert)
# Add a colorbar
plt.colorbar(img, label='Brightness Temperature (°C)', extend='both', orientation='horizontal', pad=0.05, fraction=0.05)

# print(nc.variables)

# Insert the colorbar at the bottom
	
# # Add a black rectangle in the bottom to insert the image description
# lon_difference = (extent[1] - extent[0]) # Max Lon - Min Lon
# currentAxis = plt.gca()
# currentAxis.add_patch(Rectangle((extent[0], extent[2]), lon_difference, lon_difference * 0.050, alpha=1, zorder=3, facecolor='black'))
	
# Add the image description inside the black rectangle 
# lat_difference = (extent[3] - extent[2]) # Max lat - Min lat
# plt.text(extent[0], extent[2] + lat_difference * 0.003,Title,horizontalalignment='left', color = 'white', size=10)
	
plt.show()
# Save the result
# # plt.savefig('E:\\VLAB\\Python\\Output\\INPE_G16_CH' + str(Band) + '_' + Start + '.png', dpi=DPI, bbox_inches='tight', pad_inches=0)


