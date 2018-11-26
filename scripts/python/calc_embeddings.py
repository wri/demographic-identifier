import os
import numpy as np

data_en = "../../data/muse/en/tweets_en.txt"
embedding_en = "../../data/muse/wiki.multi.en.vec"

embeddings_index = {}

f = open(embedding_en)
for i, line in enumerate(f):
	values = line.strip().split()
	if i != 168423:
		word = values[0]
		coefs = np.asarray(values[1:], dtype = "float32")
		embeddings_index[word] = coefs
f.close()

tweets = []
for line in open(data_en):
	tweets.append(line)

sent_embeddings = []
for i, tweet in enumerate(tweets):
	twt = tweets[i].split()
	embs = []
	for i in twt:
		emb.append(embeddings_index.get(i))