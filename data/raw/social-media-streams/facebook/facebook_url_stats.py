#!/usr/bin/python

import datetime
import json
import facebook

token = ""
graph = facebook.GraphAPI(access_token=token, version="3.0")


urls = [
    "http://afr100.org/content/3rd-afr100-annual-partnership-meeting",
    "http://afr100.org/content/global-landscapes-forum-nairobi-2018",
    "http://afr100.org/content/home",
    "http://www.nepad.org/content/3rd-afr100-annual-partnership-meeting",
    "https://events.globallandscapesforum.org/nairobi-2018/",
    "https://events.globallandscapesforum.org/nairobi-2018/about/",
    "https://events.globallandscapesforum.org/nairobi-2018/agenda/",
    "https://events.globallandscapesforum.org/nairobi-2018/concept-note/",
    "https://events.globallandscapesforum.org/nairobi-2018/have-your-say/",
    "https://events.globallandscapesforum.org/nairobi-2018/join-online/",
    "https://events.globallandscapesforum.org/nairobi-2018/photo-competition/",
    "https://events.globallandscapesforum.org/nairobi-2018/quiz-landscape-restoration-africa/",
    "https://events.globallandscapesforum.org/nairobi-2018/shape-the-conversation/",
    "https://events.globallandscapesforum.org/nairobi-2018/speakers/",
    "https://events.globallandscapesforum.org/nairobi-2018/youth-leaders-at-glf-nairobi-2018/",
    "https://news.globallandscapesforum.org",
    "https://twitter.com/Afr100_Official",
    "https://twitter.com/GlobalLF",
    "https://www.globallandscapesforum.org",
    "https://www.instagram.com/globallandscapesforum",
    "https://www.youtube.com/GlobalLandscapesForum",
]

shares = []
for url in urls:
    # Get stats from a URL
    url_stat = graph.get_object(id=url, fields='engagement,og_object')
    shares.append(url_stat)

timestamp = datetime.datetime.now().strftime("%Y-%m-%d-%H")
with open("urlshares.log.%s.json" % timestamp, "w") as out_file:
    for url_stat in shares:
        out_file.write(json.dumps(url_stat) + "\n")
