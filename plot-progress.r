ma <- function(arr, n=15){
  res = arr
  for(i in n:length(arr)){
    res[i] = mean(arr[(i-n):i])
  }
  res
}

a <- read.table('squeue.log');
d <- diff(a$V7);
e <- d[d < 0];
summary(e)
plot(ma(e,50))

