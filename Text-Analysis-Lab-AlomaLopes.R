setwd('D:\\Sem 3\\DV\\text-analysis-lab(1)\\text-analysis-lab')
library(tm)
library(wordcloud)
library(igraph)

####Question 01###########
#now, load trump_debate.txt & clinton_debate.txt
clinton_debate <- read.table("clinton_debate.txt",header = FALSE, sep = "\t", strip.white = TRUE,
                             quote=NULL, comment="")
trump_debate <- read.table("trump_debate.txt", header = FALSE, sep = "\t", strip.white = TRUE,
                           quote=NULL, comment="")

#process both corpora and generate two wordcloud figures.
#generating wordcloud for Clinton debate
corp1 <- Corpus(VectorSource(clinton_debate))
dtm1 <- DocumentTermMatrix(corp1)
inspect(dtm1)
#cleaning the data
# removing stop words
corp1 <- tm_map(corp1, removeWords, stopwords("english"))
wordcloud(corp1, min.freq=10, color=brewer.pal(6, "Dark2") )

#generating wordcloud for trump debate
corp2 <- Corpus(VectorSource(trump_debate))
dtm2 <- DocumentTermMatrix(corp2)
inspect(dtm2)
corp2 <- tm_map(corp2, removeWords, stopwords("english"))
wordcloud(corp2, min.freq=10, color=brewer.pal(6, "Dark2") )

#generate topic models using LDA(Latent Dirichlet Allocation)
#topic model for clinton_debate
library(lda)
doclines <- lexicalize(corp1)
result <- lda.collapsed.gibbs.sampler(doclines$documents, 10, doclines$vocab,
                                      250, 0.1, 0.1, compute.log.likelihood = TRUE)
cloud.data <- sort(result$topics[1, ], decreasing = TRUE)[1:50]
wordcloud(names(cloud.data), freq = cloud.data, scale = c(4, 0.1), min.freq = 1,
          rot.per = 0, random.order = FALSE,colors=brewer.pal(5,"Set1"))

#topic model for trump debate
library(lda)
doclines <- lexicalize(corp2)
result <- lda.collapsed.gibbs.sampler(doclines$documents, 10, doclines$vocab,
                                      250, 0.1, 0.1, compute.log.likelihood = TRUE)
cloud.data <- sort(result$topics[1, ], decreasing = TRUE)[1:50]
wordcloud(names(cloud.data), freq = cloud.data, scale = c(4, 0.1), min.freq = 1,
          rot.per = 0, random.order = FALSE,colors=brewer.pal(5,"Set1"))

##Difference between the wordclouds without topic modelling and with LDA is that,
#the later has the words arranged and visualised in different colors and classified by topic.
#The classification is evident as similar words have the same color using topic modelling.

######Q2: #Q2: generate both candidate debate word relation network figures. (1pt)##########
#plot word relations
#Clinton_debate

##Question 3: How do you compare wordclouds#######
#Ans: We can compare wordclouds by classifying the words into different emotions
#using the sentiment package. We can identify the likely association between words
#with the help of the polarity attached to them.

###Question 4: What Types of visualisations are good for showing polarities?###
# In my opinion, visualisations that show a wordcloud and then depict the polarities using
#separate colors for every emotion and also the wordcloud divided by colors based on polarities/
#emotions is the best way to show polarities. Also, the polarity label can be placed on the
#wordcloud for best recognising the emotion.


#####Q5: What are both candidate's first debate sentiment scores?#####

library(plyr)
library(stringr)
score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  
  # we got a vector of sentences. plyr will handle a list or a vector as an "l" for us
  # we want a simple array of scores back, so we use "l" + "a" + "ply" = laply:
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # and convert to lower case:
    sentence = tolower(sentence)
    
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

#load lexicon: positive & negative words into R
pos = scan('positive-words.txt', what='character',
           comment.char=';')
neg = scan('negative-words.txt', what='character',
           comment.char=';')
#customized dictionary (optional)
pos.words = c(pos, 'upgrade','lol')
neg.words = c(neg, 'wtf', 'wait', 'waiting', 'epicfail', 'mechanical')
clinton.sentiment = score.sentiment(clinton_debate, pos.words, neg.words)
clinton_score <-clinton.sentiment$score
trump.sentiment = score.sentiment(trump_debate, pos.words, neg.words)
trump_score <-trump.sentiment$score

#Trump's sentiment score = 120
#Clinton's sentiment score = 136