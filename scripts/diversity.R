library("dplyr")

#Load the dataset
data <- read.csv("sampleTaxonData/foundTaxa.csv", sep = "|")

#Get a list of unique species
species <- c()
for (i in 1:nrow(data)) {
  initial <- substr(data[i,]$genus, 1, 1)
  name <- data[i,]$species
  species[i] <- paste(initial, name)
}

#Create a function to organize a dataframe with taxon in one column and number of individuals in the other, with taxa with less than 5 individuals excluded
getNiceTable <- function(x) {
  tabl <- x[! x == ""] %>%
    as.factor() %>%
    table() %>%
    data.frame() %>%
    filter(Freq >= 5)
  colnames(tabl) <- c("taxon", "count")
  return(tabl)
}

#A function to calculate the Shannon index of a population for a given taxonomical level
getShannon <- function(x) {
  x <- getNiceTable(x)
  shan <- 0
  popsize <- sum(x$count)
  for (i in 1:nrow(x)) {
    specificCount <- x[i,]$count
    p <- specificCount / popsize
    specificShan <- - p * log(p)
    shan <- shan + specificShan
  }
  return(shan)
}

#A function to calculate the richness of a population for a given taxonomical level
getRichness <- function(x) {
  x <- getNiceTable(x)
  return(nrow(x))
}

#Calculating all indices
speciesShan <- getShannon(species)
speciesRich <- getRichness(species)

genusShan <- getShannon(data$genus)
genusRich <- getRichness(data$genus)

familyShan <- getShannon(data$family)
familyRich <- getRichness(data$family)

orderShan <- getShannon(data$order)
orderRich <- getRichness(data$order)

classShan <- getShannon(data$class)
classRich <- getRichness(data$class)

phylumShan <- getShannon(data$phylum)
phylumRich <- getRichness(data$phylum)

#Organizing the statistics in question into a dataframe
output <- data.frame(Measure = c("SpeciesShannon",
                                 "GenusShannon",
                                 "FamilyShannon",
                                 "OrderShannon",
                                 "ClassShannon",
                                 "PhylumShannon",
                                 "SpeciesRichness",
                                 "GenusRichness",
                                 "FamilyRichness",
                                 "OrderRichness",
                                 "ClassRichness",
                                 "PhylumRichness"),
                     Value = c(speciesShan,
                               genusShan,
                               familyShan,
                               orderShan,
                               classShan,
                               phylumShan,
                               speciesRich,
                               genusRich,
                               familyRich,
                               orderRich,
                               classRich,
                               phylumRich))

#Exporting the dataframe to a tsv file
write.table(output, file = "output/diversity.tsv", quote = FALSE, sep = "\t", row.names = FALSE)

