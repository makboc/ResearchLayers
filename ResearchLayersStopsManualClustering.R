cat("Stops clustering...\n")

# Source to functions
source(paste(FUNCTIONS_DIRECTORY, "SummaryByGroup.R", sep = ""))
source(paste(FUNCTIONS_DIRECTORY, "AddRowDiff.R", sep = ""))

# Import data
load(paste(DATA_DIRECTORY, "cleanBlipsType1.RData", sep = ""))
blips <- cleanBlips
cleanBlips <- NULL

# Order data
blips <- blips[order(mmsi, ts), ]

blipsCopy <- blips

# Add row differences
blips <- AddRowDiff(blips)

if (OUTPUT_LAYER_TYPE == "block") {
    
    # Check if blip maintain condition of stop in block
    blips[, isSameStop:= (locDist < blipInDockClass["locDist"] &
                                   tsDist < blipInDockClass["timeDist"] &
                                   latDist < blipInDockClass["latDist"] &
                                   lonDist < blipInDockClass["lonDist"]), 
          by = mmsi]
    
    if ("sog" %in% colnames(blips))
        blips[, isSameStop:= isSameStop &
                  sog < blipInDockClass["speed"],
              by = mmsi]       
    
    if ("th" %in% colnames(blips))
        blips[, isSameStop:= isSameStop &
                  headingDist < blipInDockClass["headDist"],
              by = mmsi]
    
    blips[is.na(isSameStop), isSameStop:= TRUE]

    # Give indeces for each stop
    blips[, stopIndex:= cumsum(!blips[, isSameStop])]
    
    # Remove blips not from same stop
    blips <- blips[blips[, isSameStop], ]
    
    # Convert data to stop aggregates
    stops <- SummaryByGroup(blips, c("mmsi", "stopIndex"))
    
    # Keep long stops
    stops <- stops[difftime(tsMax, tsMin, units = "hours") > STOP_DURATION_MIN, ]
    
    # Keep stops with at least minimum number of blips
    stops <- stops[countBlips > stopInDockClass["blipCount"], ]
    
    # Save R data
    save(stops, file = paste(DATA_DIRECTORY, "stopsInBlocks.RData", sep = ""))
    
} else {
    
    ##############################
    #
    # DOCKS
    
    # Check if blip maintain condition of stop in dock
    blips$isSameStopDock <- (blips$locDist < blipInDockClass["locDist"] &
                                 blips$tsDist < blipInDockClass["timeDist"] &
                                 blips$sameMmsi &
                                 blips$latDist < blipInDockClass["latDist"] &
                                 blips$lonDist < blipInDockClass["lonDist"])
    
    if ("sog" %in% colnames(blips)) {
        blips$isSameStopDock <- blips$isSameStopDock &
            blips$sog < blipInDockClass["speed"] & 
            blips$speedDist < blipInDockClass["speedDist"]       
    }
    
    if ("th" %in% colnames(blips)) {
        blips$isSameStopDock <- blips$isSameStopDock &
            blips$headingDist < blipInDockClass["headDist"]      
    }
    
    # Give indeces for each stop
    blips$stopIndexDock <- cumsum(!blips$isSameStopDock)
    
    # Remove blips not from same stop
    blipsInDocks <- blips[blips$isSameStopDock, ]
    
    # Convert data to stop aggregates
    stopsInDocks <- summaryByGroup(blipsInDocks, c("mmsi", "stopIndexDock"))
    
    # Keep long stops
    stopsInDocksFiltered <- stopsInDocks[difftime(stopsInDocks$ts.max,
                                                  stopsInDocks$ts.min, units = "hours") > minStopDuration, ]
    
    # Keep stops with at least minimum number of blips
    stopsInDocksFiltered <- stopsInDocksFiltered[stopsInDocksFiltered$countBlips > stopInDockClass["blipCount"], ]
    
    # Save R data
    saveRDS(stopsInDocksFiltered, paste(dataDir, "stopsInDocks.rds", sep = ""))
    
    #######################################################
    #
    # SBM
    cat("    in process: sbm clustering\n")
    
    # Import data
    blips <- readRDS(paste(dataDir, "cleanBlips.rds", sep = ""))
    
    # Order data
    blips <- blips[order(blips$mmsi, blips$ts), ]
    
    # Add row differences
    blips <- addRowDiff(blips)
    
    # Check if blip maintain condition of stop in sbm
    blips$isSameStopSBM <- (blips$locDist < blipInSBMClass["locDist"] &
                                blips$timeDist < blipInSBMClass["timeDist"] &
                                blips$sameMmsi &
                                blips$latDist < blipInSBMClass["latDist"] &
                                blips$lonDist < blipInSBMClass["lonDist"])
    
    if ("sog" %in% colnames(blips))
        blips$isSameStopSBM <- blips$isSameStopSBM &
            blips$sog < blipInDockClass["speed"] & 
            blips$speedDist < blipInSBMClass["speedDist"]       

    if ("th" %in% colnames(blips))
        blips$isSameStopSBM <- blips$isSameStopSBM &
            blips$headingDist < blipInSBMClass["headDist"]      

    # Give indeces for each stop
    blips$stopIndexSBM <- cumsum(!blips$isSameStopSBM)
    
    # Remove blips not from same stop
    blipsInSBM <- blips[blips$isSameStopSBM, ]
    
    # Convert data to stop aggregates
    stopsInSBM <- summaryByGroup(blipsInSBM, c("mmsi", "stopIndexSBM"))
    
    # Keep long stops
    stopsInSBMFiltered <- stopsInSBM[difftime(stopsInSBM$ts.max,
                                              stopsInSBM$ts.min, units = "hours") > minStopDuration, ]
    
    # Keep stops with at least minimum number of blips
    stopsInSBMFiltered <- stopsInSBMFiltered[stopsInSBMFiltered$countBlips > stopInSbmClass["blipCount"], ]
    
    # Save R data
    saveRDS(stopsInSBMFiltered, paste(dataDir, "stopsInSBM.rds", sep = ""))
    
}

cat("Stops clustering is completed!!\n")
