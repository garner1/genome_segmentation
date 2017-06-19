library(Biostrings)
require(BSgenome.Hsapiens.UCSC.hg19)
library(data.table)  

# chromosome names
cnames = seqnames(Hsapiens)[1:24]

# loop of the dimensions of the markov chain, with in_dim from 3 to 8 and out_dim from 6 to 1, respectivelly 
for(in_dim in 3:8){
out_dim = 9-in_dim

name = cnames[21]
print(name)
seqChr = unmasked(Hsapiens[[name]]) # get the chromosome sequence
  
# Move from left to right
Tmat_LR = oligonucleotideTransitions(seqChr, left = in_dim, right = out_dim, as.prob = FALSE)
# generate windows on the chromosome:
windows <- Views(seqChr, start=seq(from=1,to=length(seqChr)-(in_dim + out_dim), by=1), width = in_dim+out_dim)
# transform Views to a dataframe to be able to write to file using an efficient library
df <- rbind(data.frame(start=start(windows), end=end(windows), seq=as.character(windows)))
filename <- paste('/media/DS2415_seq/Genome_segmentation/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_LR.csv', sep='')
fwrite(x=df, file=filename, append=FALSE, row.names=FALSE)
  
Tmat_LR_norm <- -log(Tmat_LR/rowSums(Tmat_LR)) # evaluate the information of the probability

key <- c()
value <- c()
i <- 0
for(row in 1:4**in_dim){
  for(col in 1:4**out_dim){
    i <- i+1
    key[[i]] <- paste(rownames(Tmat_LR)[row],colnames(Tmat_LR)[col],sep = '')
    value[[i]] <- Tmat_LR_norm[row,col]
  }
}
df <- data.frame(key,value)
filename <- paste("/media/DS2415_seq/Genome_segmentation/transitionMatrix_",as.character(in_dim),"to",as.character(out_dim),"_LR.csv", sep = '')
fwrite(x=df, file=filename, append=FALSE, row.names=TRUE)
}

# # Move from right to left
# Tmat_RL = oligonucleotideTransitions(reverse(seqChr), left = in_dim, right = out_dim, as.prob = FALSE)
# # generate windows on the chromosome:
# windows <- Views(reverse(seqChr), start=seq(from=1,to=length(seqChr)-(in_dim + out_dim), by=1), width = in_dim+out_dim)
# # transform Views to a dataframe to be able to write to file using an efficient library
# df <- rbind(data.frame(start=start(windows), end=end(windows), seq=as.character(windows)))
# filename <- paste('/media/DS2415_seq/Genome_segmentation/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_RL.csv', sep='')
# fwrite(x=df, file=filename, append=FALSE, row.names=FALSE)
# Tmat_RL_norm <- -log(Tmat_RL/rowSums(Tmat_RL)) # evaluate the information of the probability
# 
# key <- c()
# value <- c()
# i <- 0
# for(row in 1:4**in_dim){
#   for(col in 1:4**out_dim){
#     i <- i+1
#     key[[i]] <- paste(rownames(Tmat_RL)[row],colnames(Tmat_RL)[col],sep = '')
#     value[[i]] <- Tmat_RL_norm[row,col]
#   }
# }
# df <- data.frame(key,value)
# filename <- paste("/media/DS2415_seq/Genome_segmentation/transitionMatrix_",as.character(in_dim),"to",as.character(out_dim),"_RL.csv", sep = '')
# fwrite(x=df, file=filename, append=FALSE, row.names=TRUE)
# }
