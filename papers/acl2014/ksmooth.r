#!/usr/bin/env R --slave -f
dat <- read.table(pipe("zcat summarize.0.gz | perl -pe s/\\'/^/g"), col.names=c("name", "tagp", "freq", "v4", "subs", "v6", "otpw", "v8", "word", "v10", "wsub"))
attach(dat)
tagp1 <- tagp[tagp>1]
word1 <- word[tagp>1]
subs1 <- subs[tagp>1]
bw <- 1.0
kword <- ksmooth(tagp1, word1, "normal", bw)
ksubs <- ksmooth(tagp1, subs1, "normal", bw)
output <- data.frame(kword$x, kword$y, ksubs$y)
write.table(output, file="ksmooth.out", col.names=FALSE, row.names=FALSE)

## > length(word)
## [1] 49205
## > r <- tagp>2
## > length(word[r])
## [1] 832
## > length(word[r])/length(word)
## [1] 0.01690885
## > sum(freq[r])
## [1] 0.0501795
## > mean(word[r])
## [1] 0.3871478
## > mean(subs[r])
## [1] 0.4111982
## > sum(word[r]*freq[r])/sum(freq[r])
## [1] 0.4277153
## > sum(subs[r]*freq[r])/sum(freq[r])
## [1] 0.4272569
