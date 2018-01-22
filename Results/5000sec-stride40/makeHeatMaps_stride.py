import numpy as np
import numpy.random
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.axes_grid1 import make_axes_locatable
import csv


heatmaps = []
dTau = 5
stride = 40

for i in range(26):
    heatmap = []
    with open('./csv/heatmap-{:d}.csv'.format(i*stride), newline='') as csvfile:
        content = csv.reader(csvfile, delimiter=' ', quotechar='|')

        for row in content:
            heatmap.append(np.fromstring(row[0], dtype=float, sep=','))
    heatmaps.append(heatmap)


    # Plot heatmap
    fig, ax = plt.subplots(nrows=1, ncols=1)
    im = ax.imshow(heatmaps[i], cmap='hot')
    ax.invert_yaxis()
    plt.xlabel('4 centimeters')
    plt.ylabel('4 centimeters')
    ax.set_title('Oven door glass window after: {:d} seconds'.format(dTau*i*stride))
    cbar = fig.colorbar(im)
    cbar.set_label('temperature [℃]')
    plt.savefig('./png/heatmap-{:d}.png'.format(i*stride))
    plt.close(fig)
