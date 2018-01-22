import numpy as np
import numpy.random
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable
import csv


heatmaps = []
dTau = 600
for i in range(11):
    heatmap = []
    with open('heatmap-{:d}.csv'.format(i), newline='') as csvfile:
        content = csv.reader(csvfile, delimiter=' ', quotechar='|')

        for row in content:
            heatmap.append(np.fromstring(row[0], dtype=float, sep=','))
    heatmaps.append(heatmap)


    # Plot heatmap
matplotlib.rcParams.update({'font.size': 4})
fig, axes = plt.subplots(nrows=4, ncols=3)
fig.tight_layout()

for i, ax in enumerate(axes.flat):
    if i <= 10:
        im = ax.imshow(heatmaps[i], cmap='hot')
        ax.invert_yaxis()
        ax.set_title('{:d}s'.format(dTau*(i)))


        divider = make_axes_locatable(ax)
        cax = divider.append_axes("right", size="5%", pad=0.05)
        fig.colorbar(im, cax=cax)

plt.show()
