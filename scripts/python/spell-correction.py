# -*- coding: utf-8 -*-
from ekphrasis.classes.preprocessor import TextPreProcessor
from ekphrasis.classes.tokenizer import SocialTokenizer
from ekphrasis.dicts.emoticons import emoticons

import ssl

ssl._create_default_https_context = ssl._create_unverified_context

def ws_tokenizer(text):
    return text.split()

data_en = "../../data/muse/en/tweets_en.txt"
print("### Opening tweets ### \n")
tweets = []
for line in open(data_en):
    tweets.append(line)

print("Found {} tweets".format(len(tweets)))
print("Correcting elongated, segmented, allcaps, repeated words, spelling errors, and hashtags with the twitter 2018 corrector")

text_processor = TextPreProcessor(
    normalize=['url', 'email', 'percent', 'money', 'phone', 'user', 'time',
               'date', 'number'],
    annotate={"hashtag", "elongated", "segmented", "allcaps", "repeated", 'emphasis',
              'censored'},
    all_caps_tag="wrap",
    fix_text=True,
    segmenter="english",
    corrector="twitter_2018",
    unpack_hashtags=True,
    unpack_contractions=True,
    spell_correct_elong=True,
    tokenizer=SocialTokenizer(lowercase=True).tokenize,
    # tokenizer=ws_tokenizer,
    dicts=[emoticons]
)

prepr = []
for s in tweets:
    sent = ((" ".join(text_processor.pre_process_doc(s))))
    if len(sent.split()) > 0:
        if "…" in sent.split().pop() :
            sentsplit = sent.split()[:-2]
            sent = (" ".join(sentsplit))
    prepr.append(sent)

print(len(prepr))
for s in prepr:
    with open("../../data/processed/english_corrected.txt", "a") as f:
        f.write(s + "\n")
    f.close()