library(Biostrings)
require(BSgenome.Hsapiens.UCSC.hg19)

k <- 3

cnames <- seqnames(Hsapiens)
Tmatrices_RL <- list()
Tmatrices_LR <- list()
for( name in cnames){
  seqChr = unmasked(Hsapiens[[name]])
  print(name)

  Tmat = oligonucleotideTransitions(seqChr, left = 3, as.prob = TRUE)
  Tmatrices_RL[[name]] <- Tmat
  
  Tmat = oligonucleotideTransitions(reverse(seqChr), left = 3, as.prob = TRUE)
  Tmatrices_LR[[name]] <- Tmat
  }
rm(seqChr)
# Initialize first two bases, using whole genome freq as prior
seqChr <- unmasked(Hsapiens$chr8)
# prior <- oligonucleotideFrequency(seqChr, 6, as.prob = TRUE)
# prior_DF <- data.frame(prior)
windows <- Views(seqChr, start=seq(from=1,to=length(seqChr)-(k+1), by=1), width = k+1)
writeXStringView(windows, file="windows.fa")

# for a given Tmat create a table with row-col states merged and their probability
key <- c()
value <- c()
i <- 0
for(row in 1:64){ 
  for(col in 1:4){
    i <- i+1
    key[[i]] <- paste(rownames(Tmat)[row],colnames(Tmat)[col],sep = '')
    value[[i]] <- Tmat[row,col]
  } 
}
df <- data.frame(key,value)
write.csv(df,file = "transition_matrix.csv")
