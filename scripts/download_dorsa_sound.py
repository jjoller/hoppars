import csv
import os
import urllib
import re

with open('../dorsa/multimedia.csv', 'rb') as mediafile:
    csvreader = csv.DictReader(mediafile, delimiter='	')
    audiodict = {}
    for row in csvreader:
        if "sound" in row['references']:
            audiodict[row['gbifID']] = row['references']
    with open('../dorsa/verbatim.csv', 'rb') as csvfile:
        csvreader = csv.DictReader(csvfile, delimiter='	')
        data = {}
        count = 0
        for row in csvreader:
            if 'scientificName' in row and row['gbifID'] in audiodict:
                name = row['scientificName']
                if not name in data:
                    data[name] = []
                data[name].append(audiodict[row['gbifID']])
                count = count + 1
        print(("species: ", len(data), " count: ", count))

        # download the data
        for name, sounds in list(data.items()):
            # create a folder for the species
            if not os.path.exists('data/' + name):
                os.makedirs('data/' + name)

            # download the sound files for the species
            for soundurl in sounds:

                # extract the objid from the url
                pattern = r"(.*)(objid=)([0-9]+)"
                match = re.match(pattern, soundurl)
                objid = match.group(3)
                path = 'data/' + name + "/song" + objid + ".wav"

                # check if the file has already been downloaded
                if not os.path.exists(path):
                    # download the file
                    print(("download " + soundurl))
                    f = urllib.request.urlopen(soundurl)
                    with open(path, "wb") as soundfile:
                        soundfile.write(f.read())
                else:
                    print(("the file " + soundurl + " already exists"))
