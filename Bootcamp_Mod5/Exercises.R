print(paste('current time is: ', format(Sys.time(), "%a %b %d %X %Y")))

curtime <- Sys.time()

readline(prompt="Press [enter] to continue")

print(paste(Sys.time()-curtime), ' seconds have elapsed')