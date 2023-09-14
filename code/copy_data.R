# ---------------------------------------------------------
# Created by: Jamie Duncan
# Date: 2023
# Description: Import and save local copy of project data from OneDrive path
# ---------------------------------------------------------

pacman::p_load(purrr)

drive <-  "/Path/to/files/in/cloud"

local <- "data/"

drive_files <- list.files(drive, full.names = TRUE)

local_files <- paste0(local, basename(drive_files))

walk(1:length(drive_files), \(x){
  file.copy(drive_files[x], local_files[x])
})

