#########################################################
#                                                       
# USER INPUT                                   
#

WORKING_DIRECTORY <- "/Users/maksim/Dropbox (Windward)/workspaceR/"
DATA_DIRECTORY <- "/Users/maksim/Dropbox (Windward)/ResearchLayers/Military/"
FUNCTIONS_DIRECTORY <- "/Users/maksim/Dropbox (Windward)/workspaceR/R/fun/"
VESSELS_CLASS <- "Military"
RAW_DATA_PATTERN <- "data"

DATE_MIN = as.Date("2015-01-01")
DATE_MAX = as.Date("2015-09-01")

LAT_MIN = NULL
LAT_MAX = NULL
LON_MIN = NULL
LON_MAX = NULL

QUERY_VESSELS_CLASS <- 6

OUTPUT_LAYER_TYPE <- "block" # block or dock/sbm
 
STOP_DURATION_MIN <- 1





# Blip classifiers
blipInDockClass <- c(speed = 0.3, locDist = 15, headDist = 2,
                     latDist = 9e-05, lonDist = 1.0e-04, timeDist = 2,
                     speedDist = 0.2)

blipInSBMClass <- c(speed = 0.3, locDist = 140, headDist = 25,
                    latDist = 0.0008, lonDist = 0.0009, timeDist = 2,
                    speedDist = 0.3)

# Stop Classifiers
stopInDockClass <- c(latStd = 1.317e-04, lonStd = 1.739e-04, speedStd = 0.09842,
                     locDistStd = 26.068, headDistStd = 3.4120, blipCount = 5)

stopInSbmClass <- c(latStd = 2.537e-03 , lonStd = 3.955e-05, speedStd = 0.12207,
                    locDistStd = 240.831, headDistStd = 48.5738, blipCount = 5)

# Minimal stop duration

# Dock's dimensions
dimensions <- data.frame(distToBow = 280,
                         distToStern = 50,
                         distToPort = 30,
                         distToStarboard = 30)

# SBM's radius
SBM_RADIUS <- 600

BLOCK_SIZE <- 50

# Define lat/lon grid properties
LAT_GRID_SIZE <- 5
LON_GRID_SIZE <- 5



#########################################################
#
# GET RAW DATA
#
source(paste(FUNCTIONS_DIRECTORY, "ResearchLayersGetRawData.R", sep = ""), chdir = TRUE)

#########################################################
#
# CLEAN RAW DATA
#
source(paste(FUNCTIONS_DIRECTORY, "ResearchLayersCleanRawData.R", sep = ""), chdir = TRUE)

#########################################################
#
# STOPS CLUSTERING
#
source(paste(FUNCTIONS_DIRECTORY, "ResearchLayersStopsManualClustering.R", sep = ""), chdir = TRUE)

#########################################################
#
# CREATE DOCKS
#
source(paste(FUNCTIONS_DIRECTORY, "createBlock.R", sep = ""), chdir = TRUE)

#########################################################
#
# CREATE SBM
#
#source("createSBM.R")

#########################################################
#
# UNION OF POLYGONS
#
source(paste(FUNCTIONS_DIRECTORY, "unionOfPolygons.R", sep = ""), chdir = TRUE)

#########################################################
#
# NEW POLYGONS STATISTICS
#
source("newPolyStat.R")






