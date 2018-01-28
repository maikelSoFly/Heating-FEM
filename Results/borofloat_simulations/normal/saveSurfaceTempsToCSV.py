import csv
import os
import numpy as np
import glob

l_surf_temps = []
l_surf_index = 0
r_surf_temps = []
r_surf_index = -1
writeFilename = 'surf-temps.csv'

path = './csv'
name_list = os.listdir(path)
full_list = [os.path.join(path,i) for i in name_list]
time_sorted_list = sorted(full_list, key=os.path.getmtime)
time_sorted_list.remove('./csv/.DS_Store')

for filename in time_sorted_list:
    print(filename)


for filename in time_sorted_list:
    with open(filename, newline='', encoding='utf8') as csvfile:
        reader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        row = np.fromstring(next(reader)[0], dtype=float, sep=',')
        l_surf_temps.append(row[l_surf_index])
        r_surf_temps.append(row[r_surf_index])


with open(writeFilename, 'w') as csvfile:
    writer = csv.writer(csvfile, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    for i in range(len(l_surf_temps)):
        writer.writerow([i, l_surf_temps[i], r_surf_temps[i]])
