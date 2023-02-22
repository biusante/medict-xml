"""
Download a book fron the iiif of Gallica with a workaroud
to avoir limits of the server.
proxy_randomizer does not work
A delay of 3s is not sufficient.
This random delay between 7s to 25s seems OK (but slow)
This is not a a generic script.
"""

import os
import random
import requests
import sched
import shutil
import time


ark = "bpt6k63332026"
url_form = "https://gallica.bnf.fr/iiif/ark:/12148/" + ark + "/f{0}/full/full/0/native.jpg"
dst_dir =  os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'out', ark)
os.makedirs(dst_dir, exist_ok=True)
dst_form = dst_dir + "/" + ark + "_{0}.jpg"
counter = 1
pages = 620


def do_load(scheduler):
    global counter, url_form, dst_form
    delay = random.randrange(7000, 25000) / 1000.0
    # schedule the next call first
    scheduler.enter(delay, 1, do_load, (scheduler,))
    url = url_form.format(counter)
    dst = dst_form.format(counter)
    print(url + " > " + dst)
    response = requests.get(url, stream=True)
    with open(dst, 'wb') as dst_handle:
        shutil.copyfileobj(response.raw, dst_handle)
        del response
    if counter >= pages:
        exit()
    counter = counter + 1
        
my_scheduler = sched.scheduler(time.time, time.sleep)
my_scheduler.enter(0, 1, do_load, (my_scheduler,))
my_scheduler.run()
