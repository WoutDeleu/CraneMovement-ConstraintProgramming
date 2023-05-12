import matplotlib.pyplot as plt

VPos = [737, 665, 109, 665, 584, 21, 337, 650, 108, 536, 455, 21, 208, 337, 140, 179, 303, 21, 21, 21]
tmshft = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
qcbasepositions = [21,50,79,109,138,168,197,226,256,285,315,344,374,403,432,462,491,521,550,580]
length = [200,67,70,71,70,89,141,76,89,103,118,108,80,188,152,147,141,76,76,147]
ARV = [30,137,82,113,103,34,66,20,7,33,119,121,3,4,110,40,103,8,89,60]
DPT = [54,3,106,128,151,58,86,40,31,65,151,145,27,60,146,78,139,32,113,76]

fig, ax = plt.subplots()

# Plot rectangles for each vessel
for i in range(len(VPos)):
    start = VPos[i]
    end = start + length[i]
    if DPT[i] < ARV[i]:
        height1 = 168 - (ARV[i] + tmshft[i])
        height2 = DPT[i] + tmshft[i]
        rectangle1 = plt.Rectangle((start, ARV[i] + tmshft[i]), end - start, height1, facecolor='yellow', edgecolor='black')
        rectangle2 = plt.Rectangle((start, 0), end - start, height2, facecolor='yellow', edgecolor='black')
        ax.add_patch(rectangle1)
        ax.add_patch(rectangle2)
    else:
        height = (DPT[i] + tmshft[i]) - (ARV[i] + tmshft[i])
        rectangle = plt.Rectangle((start, ARV[i] + tmshft[i]), end - start, height, facecolor='red', edgecolor='black')
        ax.add_patch(rectangle)

# Plot colored lines for each crane
colors = ['red', 'blue', 'green', 'orange', 'purple', 'brown', 'pink', 'gray', 'olive', 'cyan', 'magenta', 'black', 'lime', 'navy', 'teal', 'salmon', 'gold', 'indigo', 'violet', 'turquoise']
for i, pos in enumerate(qcbasepositions):
    ax.axvline(x=pos, color=colors[i], linestyle='--', linewidth=2)
    ax.axvline(x=pos+400, color=colors[i], linestyle='--', linewidth=2)

# Set axis labels and limits
ax.set_xlabel('Quay Position')
ax.set_ylabel('Time')
ax.set_xlim(0, max(VPos) + max(length))
ax.set_ylim(0, 168)

# Set aspect ratio to 'auto' for better visualization of rectangles
ax.set_aspect('auto')

# Display the plot
plt.show() 