#!/usr/bin/env Rscript
library(stringr)

checkrealanimal <- function() {
  flnm <- "animals.txt"
  success <- FALSE
  while (!success) {
    testanimal <- readline(prompt="What is your favorite animal (singular form)?")
    my_data <- tolower(readChar(flnm, file.info(flnm)$size))
    my_data <- str_replace_all(my_data, "[\n]", " ")
    
    success <- grepl(tolower(favan),my_data, fixed = TRUE)
    return("not quite, try again")
  }
  return("that's a real animal, nice one!")
}

print(paste('current time is: ', format(Sys.time(), "%a %b %d %X %Y")))

curtime <- Sys.time()

readline(prompt="Press [enter] to continue")

print(paste(Sys.time()-curtime, ' seconds have elapsed'))

print(checkrealanimal())