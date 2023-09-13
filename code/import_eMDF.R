# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Description: Import and save local copy of Extended Moral Foundations Dictionary (eMFD) from source https://github.com/medianeuroscience/emfd
# ---------------------------------------------------------
pacman::p_load(readr)

emf_dict <- read_csv("https://raw.githubusercontent.com/medianeuroscience/emfd/master/dictionaries/emfd_scoring.csv")

write_csv(emf_dict, "data/emfd_scoring.csv")
