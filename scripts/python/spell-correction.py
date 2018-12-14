# -*- coding: utf-8 -*-
from ekphrasis.classes.preprocessor import TextPreProcessor
from ekphrasis.classes.tokenizer import SocialTokenizer
from ekphrasis.dicts.emoticons import emoticons

import ssl

ssl._create_default_https_context = ssl._create_unverified_context

# Print iterations progress
def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█'):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print('\r%s |%s| %s%% %s' % (prefix, bar, percent, suffix), end = '\r')
    # Print New Line on Complete
    if iteration == total: 
        print()


def ws_tokenizer(text):
    return text.split()

data_en = "../../data/processed/english_text.txt"
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

printProgressBar(0, len(tweets), prefix = "Progress:", suffix = "Complete", length = 50)
prepr = []
for s, twt in enumerate(tweets):
    sent = ((" ".join(text_processor.pre_process_doc(twt))))
    if len(sent.split()) > 0:
        if "…" in sent.split().pop() :
            sentsplit = sent.split()[:-2]
            sent = (" ".join(sentsplit))
    printProgressBar(s + 1, len(tweets), prefix = 'Progress:', suffix = 'Complete', length = 50)
    prepr.append(sent)

print(len(prepr))
for s in prepr:
    with open("../../data/processed/english_corrected.txt", "a") as f:
        f.write(s + "\n")
    f.close()