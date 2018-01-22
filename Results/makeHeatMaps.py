import numpy as np
import numpy.random
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable
import csv


heatmaps = []
dTau = 40

for i in range(32):
    heatmap = []
    with open('heatmap-{:d}.csv'.format(i), newline='') as csvfile:
        content = csv.reader(csvfile, delimiter=' ', quotechar='|')

        for row in content:
            heatmap.append(np.fromstring(row[0], dtype=float, sep=','))
    heatmaps.append(heatmap)


    # Plot heatmap
    fig, ax = plt.subplots(nrows=1, ncols=1)
    im = ax.imshow(heatmaps[i], cmap='hot')
    ax.invert_yaxis()
    ax.set_title('Heated oven door glass after: {:d} seconds'.format(dTau*i))
    fig.colorbar(im)
    plt.savefig('heatmap-{:d}.png'.format(i))
    plt.close(fig)
