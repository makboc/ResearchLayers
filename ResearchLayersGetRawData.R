
#setwd("~/Dropbox (Windward)/workspaceR/R/fun")
source(paste(FUNCTIONS_DIRECTORY, "QueryGetType1BlipsProd4.R", sep = ""))
#source("QueryGetType1BlipsProd3.R")
source(paste(FUNCTIONS_DIRECTORY, "QueryGetShip.R", sep = ""))
source(paste(FUNCTIONS_DIRECTORY, "QueryRunProd4.R", sep = ""), chdir = TRUE)
# source("QueryRunProd3.R")
library(data.table)


cat("Identifying fleet...")
if (!is.null(QUERY_VESSELS_CLASS)) {
    query <- QueryGetShip(classList = QUERY_VESSELS_CLASS)
    res <- QueryRunProd4(query)
    oldShipIdList <- res$oldShipId
}
cat("completed!\n")


cat("Downloading data...")
monthSeq <- seq.Date(from = DATE_MIN, to = DATE_MAX, by = "1 month")
for (monthIdx in 1:(length(monthSeq) - 1)) {
    query <- QueryGetType1BlipsProd4(tsMin = monthSeq[monthIdx], tsMax = monthSeq[monthIdx + 1],
                                     latMin = LAT_MIN, latMax = LAT_MAX,
                                     lonMin = LON_MIN, lonMax = LON_MAX,
                                     sogMax = 1, oldShipIdList = oldShipIdList)
    
    dataName <- paste(RAW_DATA_PATTERN, monthSeq[monthIdx + 1], sep = "")
    assign(dataName, QueryRunProd4(query))
    assign(dataName, data.table(get(dataName)))
    
#     helper <- function(x) {
#         query <- QueryGetType1BlipsProd3(mmsiList = data[x, mmsi], ts = data[x, ts])
#         res <- QueryRunProd3(query)
#         return(res$th)
#     }
#     res <- sapply(1:nrow(data), FUN = function(x) helper(x))
#     
    
    save(list = dataName, file = paste(DATA_DIRECTORY, dataName, ".RData", sep = ""))
    
    cat(round(monthIdx / (length(monthSeq) - 1) * 100, 1), "%..", sep = "")
}
cat("Completed!\n")


