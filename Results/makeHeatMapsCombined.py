import numpy as np
import numpy.random
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable
import csv


heatmaps = []
dTau = 40

for i in range(31):
    heatmap = []
    with open('./csv/heatmap-{:d}.csv'.format(i+1), newline='') as csvfile:
        content = csv.reader(csvfile, delimiter=' ', quotechar='|')

        for row in content:
            heatmap.append(np.fromstring(row[0], dtype=float, sep=','))
    heatmaps.append(heatmap)


# Plot heatmap
matplotlib.rcParams.update({'font.size': 4})
fig, axes = plt.subplots(nrows=6, ncols=5)
fig.tight_layout()

for i, ax in enumerate(axes.flat):
    im = ax.imshow(heatmaps[i], cmap='hot')
    ax.invert_yaxis()
    ax.set_title('{:d}s'.format(dTau*(i+1)))


    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    fig.colorbar(im, cax=cax)

plt.show()
