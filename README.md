# demographic-identifier
Python toolkit to identify the gender, age and race of individual profiles on Twitter with computer vision and analyze demographic-level differences in topic discussions.

## Examples
![Overview of approach](https://raw.githubusercontent.com/wri/demographic-identifier/master/img/use-2.png)
*Semantic similarity of randomly sampled Tweets about legislation, innovation, and clean water shows the ability of the Universal Sentence Encoder to cluster Tweets by meaning.*

![Summary results](https://raw.githubusercontent.com/wri/demographic-identifier/master/img/png/gender_race.png)
*Distribution of select topics by gender (left) and race (right) allows the user to understand demographic differences in topic engagement.*

## Installation

This Python + R toolkit requires a Python 3.6 environment. The dependencies can be installed with 

```
$ pip3 install -r requirements.txt
```

The R requirements `tidyverse`, `gender`, `plyr`, and `jsonlite` can be installed with

```
install.packages(c('tidyverse', 'gender', 'plyr', 'jsonlite'))
```

### Use

#### 1. Data acquisition
Input data should be in the form of a compressed streaming JSON returned from the Twitter API. The `download_data.R` script will identify all user profile images in the API results and download every image to the `img` folder.

#### 2. Age and gender identification
Running, in order, the `age-gender-image.py` and `gender_age.R` scripts will create a .CSV in the `results` folder estimating the age and gender of each twitter handle.

#### 3. Ethnicity identification
Ethnicity is estimated using the Python package [ethnicolr](https://github.com/appeler/ethnicolr) which uses character-level RNN to predict race from first and last name. After install, ethnicity can be estimated using the following bash script

```
pred_wiki_name -o {output.csv} -l last.name -f first.name {input.csv}
```

#### 4. Visualization
The `demographic_summary.R` script will create a summary visualization of number of twitter handles by demographic. The `demographic_topics.R` script can be used to create the above figures of topic distributions by demographic.


## Methodology

![Overview of approach](https://raw.githubusercontent.com/wri/demographic-identifier/master/img/model-structure.png)

#### Model architecture
Gender is estimated using a combination of computer vision and U.S. census data. The `gender` [R package](https://github.com/ropensci/gender) matches first names to gender proportions in the U.S. census. Gender and age were also estimated using a [pre-trained](https://github.com/yu4u/age-gender-estimation) [WideResNet architecture](https://arxiv.org/pdf/1605.07146.pdf) network trained on 500,000 photographs labelled by age and gender. 

The mean error is 3 years for age, and the accuracy rate for gender is 95%. These estimates are validated by matching the name, when available, to US census data on gender percentiles by first name. In more than 95% of cases, these two estimates match. When they do not, the highest confidence estimate is used as the gender prediction. Pairing these two modes of estimating gender allows an estimate where only one of the two data sources are available (User image containing a face, or first name). 

The WideResNet architecture automatically identifies and disregards Twitter handles that do not have profile pictures containing faces. When there is more than one face, the Twitter handle is assigned the demographic most likely to belong to the name associated with the handle. Name-based identification also identifies names that are not real names, which are about 15% of Twitter handles. Twitter profiles that have neither a real name nor have a facial photograph are disregarded.

#### Text cleaning

Tweets often are not grammatically correct, have spelling errors, and have hashtags. The Python module `ekphrasis` is used to clean the Twitter text data, using a language model (FastText) trained on 1 billion tweets. This automatically corrects common spelling errors, like elongating words (ex: "wooooooow"), hashtag phrases (ex: "#savetheplanet" -> "save the planet"), and converts user mentions to a single unique token. 

The `spell-correction.py` script will take an input CSV of tweets and write cleaned output to a CSV in the `data/processed` folder.

#### Semantics and topics

In order to model the semantic and topical structure of Tweets, a number of recent natural language processing approaches were tested. These include latent Bayesian approaches such as latent Dirichlet allocation (Blei, 2003), structured topic models (Roberts, 2013), biterm topic models (Yan, 2013), as well as neural embedding approaches including Word2vec (Mikelov, 2014), Tweet2vec (Vosoughi, 2016), MUSE (Conneau et al., 2018), and the Universal Sentence Encoder (Cer et al., 2018). The Universal Sentence Encoder (USE) performed better than the other tested approaches when qualitatively evaluated on sentence similarity and topic coherence.

The Universal Sentence Encoder (Cer et al., 2018) leverages transfer learning to learn task-invariant sentence representations. The pre-trained model uses the transformer architecture (Vaswani et al., 2017) to jointly learn tasks including sentiment, subjectivity, and polarity analysis as well as question classification and semantic similarity. This generalizability makes it a strong candidate for representing the topics and meanings of Tweets, which vary widely in diction and prose. 138,512 Tweets from over 135,708 unique handles were encoded with the pretrained USE model and clustered with K-nearest neighbors (KNN) clustering. Cluster amounts ranging from 50-250 were tested by reading random stratified subsamples of 20 randomly chosen topics. KNN with k = 200 was selected for final analysis based on this manual validation method. Each of the 200 topics were manually labelled by reading 50 random Tweets in each topic. Full code and descriptions are contained in the `USE-embeddings.ipnyb` notebook.

## Issues / To-do
1. Transition R scripts to python where available
2. Code commenting and documentation of pipeline
3. Clean up data folder and make data workflow more clear
