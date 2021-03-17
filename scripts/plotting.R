library("dplyr")
library("ggplot2")

#Define some important functions
getNiceTable <- function(x) {
  tabl <- x[! x == ""] %>%
    as.factor() %>%
    table() %>%
    data.frame() %>%
    filter(Freq >= 5)
  colnames(tabl) <- c("taxon", "count")
  return(tabl)
}

getTopTaxa <- function(df) {
  temp_df <- getNiceTable(df$Genus)
  temp_df <- temp_df[order(temp_df$count, decreasing = TRUE),]
  topTaxa <- as.character(temp_df$taxon[1:10])
  for (i in 1:nrow(df)) {
    if (df[i,]$Genus %in% topTaxa) {
      next
    } else {
      df[i,]$Genus <- "Other"
      df[i,]$Phylum <- "Other"
    }
  }
  return(df)
}

#Load the dataset
data <- read.csv("Downloads/foundTaxa.csv", sep = "|")

#Prepare the dataset for plotting
plotting.df <- data.frame(Phylum = data$phylum, Genus = data$genus)
plotting.df <- getTopTaxa(plotting.df)
plotting.df$Phylum[plotting.df$Phylum == ""] <- "Undefined"
plotting.df <- plotting.df[order(plotting.df$Phylum),]

namedGenus <- setdiff(plotting.df$Genus, "Other")
namedPhylum <- setdiff(plotting.df$Phylum, c("Other", "Undefined"))

plotting.df$Genus <- factor(plotting.df$Genus, levels = c(namedGenus, "Other"))
plotting.df$Phylum <- factor(plotting.df$Phylum, levels = c(namedPhylum, "Other", "Undefined"))

#Create the plots
phylum.plot <- ggplot(data = plotting.df, mapping = aes(fill = Phylum, x = "")) +
  geom_bar() +
  theme_bw() +
  scale_fill_brewer(palette = "Set3")

genus.plot <- ggplot(data = plotting.df, mapping = aes(fill = Genus, x = "")) +
  geom_bar() +
  theme_bw() +
  scale_fill_brewer(palette = "Set3")

#Output the plots as some nice SVGs
svg("output/phylum_plot.svg")
phylum.plot
dev.off()

svg("output/genus_plot.svg")
genus.plot
dev.off()
