import csv
import os
import urllib.request
import urllib.parse
import urllib.error
import re
import wave


'''
Download sound files from the DORSA https://www.dorsa.de/ repository
'''

def download(filepath, soundurl):
    # download the file
    while True:
        try:
            print(("download " + soundurl))
            f = urllib.request.urlopen(soundurl)
            with open(filepath, "wb") as soundfile:
                soundfile.write(f.read())
        except urllib.URLError:
            print("No internet connection, try again...")
        else:
            break

with open('../dorsa/multimedia.csv', 'r') as mediafile:
    csvreader = csv.DictReader(mediafile, delimiter='	')
    audiodict = {}
    for row in csvreader:
        if "sound" in row['references']:
            audiodict[row['gbifID']] = row['references']
    with open('../dorsa/verbatim.csv', 'r') as csvfile:
        csvreader = csv.DictReader(csvfile, delimiter='	')
        data = {}
        count = 0
        for row in csvreader:
            if 'scientificName' in row and row['gbifID'] in audiodict:
                name = row['scientificName']
                if not name in data:
                    data[name] = []
                data[name].append(audiodict[row['gbifID']])
                count += 1
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
                    download(path,soundurl)
                else:
                    try:
                        str(wave.open(path, 'r').getframerate())
                        #print("the file " + soundurl + " already exists, framerate is " + str(wave.open(path,'r').getframerate()))
                    except:
                        print("file " + path + " is corrupt")
                        download(path, soundurl)

