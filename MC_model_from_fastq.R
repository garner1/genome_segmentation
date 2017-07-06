library(Biostrings)

# Set the dimensions of the MC model 
in_dim = 3
out_dim = 3
  
# Specify the input fastq file
seq = readDNAStringSet("/home/garner1/tool_test/neat/test.fastq", format="fastq")

# Build the MC homogeneous transition matrix
Tmat = oligonucleotideTransitions(seq, left = in_dim, right = out_dim, as.prob = FALSE)

# Define the information content
Tmat_norm <- -log(Tmat/rowSums(Tmat))

# Build the dataframe associating to a word, obtained joining input and output state, the information
key <- c()
value <- c()
i <- 0
for(row in 1:4**in_dim){
  for(col in 1:4**out_dim){
    i <- i+1
    key[[i]] <- paste(rownames(Tmat)[row],colnames(Tmat)[col],sep = '')
    value[[i]] <- Tmat_norm[row,col]
  }
}
df <- data.frame(key,value) #THERE MIGHT BE INFINITE VALUES DUE TO DIVISION BY 0

# Define the file name of the transition matrix
filename <- paste("~/tool_test/transitionMatrix_",as.character(in_dim),"to",as.character(out_dim),".csv", sep = '')

# Write the dataframe to file
write.table(df, file=filename, row.names=FALSE, quote=FALSE, append=FALSE)  # same
