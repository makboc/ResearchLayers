#setwd("~/Dropbox (Windward)/workspaceR/R/fun")
source("UsePackages.R", local = TRUE)
UsePackages("data.table")

substrRight <- function(x, n){
    substr(x, nchar(x) - n + 1, nchar(x))
}

cat("\nCleaning raw data....")

# Remove files which created before
fileToRemove <- list.files(path = DATA_DIRECTORY, pattern = "clean")
if (length(fileToRemove) > 0) {
    do.call(file.remove, list(paste0(DATA_DIRECTORY, fileToRemove, collapse = "")))
}

# Get the files names which include pattern
files = list.files(path = DATA_DIRECTORY, pattern = RAW_DATA_PATTERN)

# Import data
fileType <- substrRight(files[1], 3)

if (fileType == "csv") {
    blips = do.call("rbind", lapply(files, function(x) read.csv(paste(dataDir, x, sep = ""), quote = "",
                                                                row.names = NULL,
                                                                stringsAsFactors = FALSE)))
} else if (fileType == "rds"){
    blips = do.call("rbind", lapply(files, function(x) readRDS(paste(dataDir, x, sep = ""))))
} else {
    blips <- data.table()
    for (file in files){
        blips <- rbind(blips, get(sub(pattern = ".RData", replacement = "", file)))
    }
}

# Select columns of interest
blips <- blips[, keepColsIndeces, with = FALSE]

# Keep slow blips
blips <- blips[sog < 0.5, ]

# Clean data
# Columns to convert to numeric
colsNum <- colnames(blips)[colnames(blips) %in% c("oldShipId", "mmsi", "lat", "lon", "sog", "cog", "th", "imo")]

# Convert columns to numeric
blips[, colsNum:= lapply(blips[, colsNum, with = FALSE], as.numeric), with = FALSE]

# Convert date time to POSIXT format
blips[, ts:=  as.POSIXct(blips[, ts], tz = "UTC", format = "%Y-%m-%d %H:%M:%S")]

# Validate lat
blips[lat < -90 | lat > 90, lat:= NA]

# Validate lon
blips[lon < -180 | lon > 180, lon:= NA]

# Replace incorrect values by NA
if ("cog" %in% colnames(blips))
    blips[cog < 0 | cog > 360, cog:= NA]

if ("th" %in% colnames(blips))
    blips[th < 0 | th > 360, th:= NA]

# Order data by MMSI and DateTime
cleanBlips <- blips[order(mmsi, ts), ]

# Save R data
save(cleanBlips, file = paste(DATA_DIRECTORY, "cleanBlips", "Type1", ".RData", sep = ""))
cat("done.")
