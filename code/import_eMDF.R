#Source : https://github.com/medianeuroscience/emfd

pacman::p_load(readr)

emf_dict <- read_csv("https://raw.githubusercontent.com/medianeuroscience/emfd/master/dictionaries/emfd_scoring.csv")

write_csv(emf_dict, "data/emfd_scoring.csv")
