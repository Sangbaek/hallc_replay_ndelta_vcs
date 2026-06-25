from glob import glob
import json
import os

data_dir     = "/cache/hallc/alphaE/ndelta_vcs2_2026_online/"
data = None
with open('../hallc_replay_ndelta_vcs/vcs2_good_runs.json', "r") as file:
  data = json.load(file)

for runs in data:
  configuration = list(runs.keys())[0]
  for i, run in enumerate(list(runs.values())[0]):
    full_replay_location = "{}/coin_replay_production_{}_-1_all.root".format(data_dir, run)
    if len(glob(full_replay_location)):
      filesize = os.path.getsize(full_replay_location)
      #print("{}".format(filesize))
      if filesize < 10000:
        print("{} run {} full replay size is too small".format(configuration, run))
      print("{} run {} full replay exists".format(configuration, run))
    else:
      print("{} run {} full replay does not exist".format(configuration, run))
    
