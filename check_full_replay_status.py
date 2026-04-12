from glob import glob
import json

data_dir     = "/net/cdaq/cdaql2data/cdaq/hallc-online-ndelta_vcs2_2026/ROOTfiles/"
data = None
with open('good_runs.json', "r") as file:
  data = json.load(file)

for runs in data:
  for run in list(runs.values())[0]:
    full_replay_location = "{}/coin_replay_production_{}_-1_all.root".format(data_dir, run)
    if len(glob(full_replay_location)):
      print("{} full replay exists".format(run))
    
