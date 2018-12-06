# demographic-identifier
Computer vision and NLP to identify age, race, and gender in photographs

## Installation

This Python + R toolkit requires a Python 3.6 virtual environment. The dependencies can be installed with 

```
$ pip3 install -r requirements.txt
```

The R requirements `tidyverse`, `gender`, `plyr`, and `jsonlite` can be installed with

```
install.packages(c('tidyverse', 'gender', 'plyr', 'jsonlite'))
```
## Methodology

The input data should be in the form of a compressed streaming json file returned from the Twitter API. The `download_data.R` file will identify all the user profile images from the API results and download every image to the `img` folder. When run in order, the `age-gender-image.py`, `process_results.R`, and `calc_gender_age.R`, scripts will return a CSV in the `results` folder that contains the twitter handle and associated estimated age and gender.

Gender is estimated using a combination of computer vision and U.S. census data. The `gender` [R package](https://github.com/ropensci/gender) matches first names to gender proportions in the U.S. census. Gender and age were also estimated using a port of the age-gender-estimation project found [here](https://github.com/yu4u/age-gender-estimation). This used the [WideResNet architecture](https://arxiv.org/pdf/1605.07146.pdf) and is trained on 500,000 labelled photographs. 

Thee mean error is 3 years for age, and the accuracy rate for gender is 95%. These estimates are validated by matching the name, when available, to US census data on gender percentiles by first name. In more than 95% of cases, these two estimates match. When they do not, the highest confidence estimate is used as the gender prediction. Pairing these two modes of estimating gender allows an estimate where only one of the two data sources are available (User image containing a face, or first name). 

Ethnicity is estimated using the Python package [ethnicolr](https://github.com/appeler/ethnicolr) which uses character-level RNN to predict race from first and last name. After install, ethnicity can be estimated using the following bash script

```
pred_wiki_name -o ../results/stream_05/output-wiki-pred-race.csv -l last.name -f first.name ../results/stream_05/results_gender_age.csv
```

Differences in semantics between demographic groups can be modelled with [neural variational inference](https://arxiv.org/abs/1511.06038) or sentence embeddings that do not rely on continuous sentences, such as [doc2vec](https://cs.stanford.edu/~quocle/paragraph_vector.pdf). With large amounts of training data, semantics may be modelled by taking the l2 norm of the summation of word level multilingual embeddings, such as [MUSE](https://github.com/facebookresearch/MUSE). 
