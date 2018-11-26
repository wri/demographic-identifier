import os
import numpy as np

data_en = "../../data/muse/en/tweets_en.txt"
embedding_en = "../../data/muse/wiki.multi.en.vec"

embeddings_index = {}
print("### Opening embeddings index ###\n")
f = open(embedding_en)
for i, line in enumerate(f):
	values = line.strip().split()
	if i != 168423:
		word = values[0]
		coefs = np.asarray(values[1:], dtype = "float32")
		embeddings_index[word] = coefs
f.close()

print("### Opening tweets ### \n")
tweets = []
for line in open(data_en):
	tweets.append(line)

print("### Calculating sentence embeddings ### \n")
sent_embeddings = []
for i, tweet in enumerate(tweets):
	twt = tweets[i].split()
	embs = []
	sent_emb = np.zeros(300)
	for i in twt:
		if embeddings_index.get(i) is not None:
			embs.append(embeddings_index.get(i))
			sent_emb += embeddings_index.get(i)
	for i in sent_emb:
		sent_emb[i] /= len(twt)
	sent_embeddings.append(sent_emb)

print("### Saving normalized sentence embeddings ### \n")
np.savetxt("../../data/processed/sent_embeddings.txt", sent_embeddings)