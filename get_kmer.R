library(Biostrings)
require(BSgenome.Hsapiens.UCSC.hg19)
library(data.table)  


# chromosome names
cnames = seqnames(Hsapiens)[1:24]

# initialization (out_dim can always be set to 1 wo loss of generalization)
in_dim = 3
out_dim = 1

for( name in cnames){
  print(name)
  seqChr = unmasked(Hsapiens[[name]]) # get the chromosome sequence

  # Move from left to right
  if (name == 'chr1'){
    Tmat_LR = oligonucleotideTransitions(seqChr, left = in_dim, right = out_dim, as.prob = FALSE)
  } else {Tmat_LR = Tmat_LR + oligonucleotideTransitions(seqChr, left = in_dim, right = out_dim, as.prob = FALSE)}
  # generate windows on the chromosome:
  windows <- Views(seqChr, start=seq(from=1,to=length(seqChr)-(in_dim + out_dim), by=1), width = in_dim+out_dim)
  # transform Views to a dataframe to be able to write to file using an efficient library
  df <- rbind(data.frame(start=start(windows), end=end(windows), seq=as.character(windows)))
  filename <- paste('~/Work/dataset/genome_segmentation/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_LR.csv', sep='')
  fwrite(x=df, file=filename, append=FALSE, row.names=FALSE)

  # Move from right to left
  if (name == 'chr1'){
    Tmat_RL = oligonucleotideTransitions(reverse(seqChr), left = in_dim, right = out_dim, as.prob = FALSE)
  } else {Tmat_RL = Tmat_RL + oligonucleotideTransitions(reverse(seqChr), left = in_dim, right = out_dim, as.prob = FALSE)}
  # generate windows on the chromosome:
  windows <- Views(reverse(seqChr), start=seq(from=1,to=length(seqChr)-(in_dim + out_dim), by=1), width = in_dim+out_dim)
  # transform Views to a dataframe to be able to write to file using an efficient library
  df <- rbind(data.frame(start=start(windows), end=end(windows), seq=as.character(windows)))
  filename <- paste('~/Work/dataset/genome_segmentation/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_RL.csv', sep='')
  fwrite(x=df, file=filename, append=FALSE, row.names=FALSE)
}
Tmat_LR_norm <- -log(Tmat_LR/rowSums(Tmat_LR))
Tmat_RL_norm <- -log(Tmat_RL/rowSums(Tmat_RL))

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
filename <- paste("~/Work/dataset/genome_segmentation/transitionMatrix_",as.character(in_dim),"to",as.character(out_dim),"_LR.csv", sep = '')
fwrite(x=df, file=filename, append=FALSE, row.names=TRUE)
# write.csv(df, file = filename)

key <- c()
value <- c()
i <- 0
for(row in 1:4**in_dim){
  for(col in 1:4**out_dim){
    i <- i+1
    key[[i]] <- paste(rownames(Tmat_RL)[row],colnames(Tmat_RL)[col],sep = '')
    value[[i]] <- Tmat_RL_norm[row,col]
  }
}
df <- data.frame(key,value)
filename <- paste("~/Work/dataset/genome_segmentation/transitionMatrix_",as.character(in_dim),"to",as.character(out_dim),"_RL.csv", sep = '')
fwrite(x=df, file=filename, append=FALSE, row.names=TRUE)
# write.csv(df, file = filename)

# for( name in cnames){
#   print(name)
#   seqChr = unmasked(Hsapiens[[name]]) # get the chromosome sequence 
#   
#   # Move from left to right
#   Tmat = oligonucleotideTransitions(seqChr, left = in_dim, right = out_dim, as.prob = TRUE) # build the transition matrix from left to right
#   key <- c()
#   value <- c()
#   i <- 0
#   for(row in 1:4**in_dim){ 
#     for(col in 1:4**out_dim){
#       i <- i+1
#       key[[i]] <- paste(rownames(Tmat)[row],colnames(Tmat)[col],sep = '')
#       value[[i]] <- Tmat[row,col]
#     } 
#   }
#   df <- data.frame(key,value)
#   filename <- paste("~/transitionMatrix_",as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),"_LR.csv", sep = '')
#   write.csv(df, file = filename)
#   
#   # generate windows on the chromosome:
#   windows <- Views(seqChr, start=seq(from=1,to=length(seqChr)-(in_dim + out_dim), by=1), width = in_dim+out_dim)
#   # transform Views to a dataframe to be able to write to file using an efficient library
#   df <- rbind(data.frame(start=start(windows),end=end(windows),seq=as.character(windows)))
#   filename <- paste('~/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_LR.csv', sep='')
#   fwrite(x=df, file=filename, append=FALSE, row.names=FALSE)
#   
#   
#   # Move from right to left
#   Tmat = oligonucleotideTransitions(reverse(seqChr),left = in_dim,as.prob = TRUE) # build the transition matrix from right to left
#   key <- c()
#   value <- c()
#   i <- 0
#   for(row in 1:4**in_dim){ 
#     for(col in 1:4**out_dim){
#       i <- i+1
#       key[[i]] <- paste(rownames(Tmat)[row],colnames(Tmat)[col],sep = '')
#       value[[i]] <- Tmat[row,col]
#     } 
#   }
#   df <- data.frame(key,value)
#   filename <- paste("~/transitionMatrix_",as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),"_RL.csv", sep = '')
#   write.csv(df, file = filename)
#   
#   # generate windows on the chromosome:
#   windows <- Views(seqChr, start=seq(from=1,to=length(seqChr)-(in_dim+out_dim), by=1), width = in_dim+out_dim)
#   # transform Views to a dataframe to be able to write to file using an efficient library
#   df <- rbind(data.frame(start=start(windows),end=end(windows),seq=as.character(windows)))
#   filename <- paste('~/views_',as.character(name),"_",as.character(in_dim),"to",as.character(out_dim),'_RL.csv', sep='')
#   fwrite(x=df, file=filename, append=FALSE,row.names=FALSE)
# }
# rm(seqChr)

# seqChr <- unmasked(Hsapiens$chr8)
# fwrite(x = df,file = 'C:/users/silvano.garnerone/views.csv',append = FALSE,row.names = FALSE)
# for a given Tmat create a table with row-col states merged and their probability
# write.csv(df,file = "C:/users/silvano.garnerone/transition_matrix.csv")

