import os
import numpy as np
from collections import Counter

data_en = "../../data/muse/en/tweets_en.txt"
#embedding_en = "../../data/muse/wiki.multi.en.vec"
embedding_en = "../../data/muse/glove.6B.300d.txt"


embeddings_index = {}
print("### Opening embeddings index ###\n")
f = open(embedding_en)
for i, line in enumerate(f):
    values = line.strip().split()
    if i % 20000 == 0:
        print(i)
    #if i != 168423:
    word = values[0]
    coefs = np.asarray(values[1:], dtype = "float32")
    embeddings_index[word] = coefs
f.close()

print("### Opening tweets ### \n")
tweets = []
for line in open(data_en):
    tweets.append(line)

print("### Generating word counts ### \n")
words = [x.split() for x in tweets]
words2 = [item for sublist in words for item in sublist]
counts = Counter(words2)
wordcount = [key for key in counts.keys() if counts.get(key) > 25]
print("{} of {} unique tokens retained.".format(len(wordcount), len(counts.keys())))

print("### Calculating sentence embeddings ### \n")

def calc_embedding(i):
    tweet = tweets[i].split()
    sent_emb = np.zeros(300)
    embs = np.zeros(300)
    length = 0
    for x in tweet:
        if x in wordcount:
            if embeddings_index.get(x) is not None:
                emb = np.asarray(embeddings_index.get(x))
                embs += emb ** 2
    total_emb = np.sqrt(embs)
    return(total_emb)
    
#embs = np.zeros(300)
embs = []
for i in range(0, len(tweets)):
    
    current_emb = calc_embedding(i)
    if type(current_emb) is float:
        current_emb = np.zeros(300)
    if i % 10000 == 0:
        print(i)
        print(current_emb)
    embs.append(current_emb)
    #embs = np.vstack((embs, current_emb))
#embs = embs[1:]

print("### Saving normalized sentence embeddings ### \n")
#print(sent_embeddings[0])
np.savetxt("../../data/processed/sent_embeddings.txt", embs)