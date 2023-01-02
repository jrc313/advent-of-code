#!/bin/bash

ffmpeg -y -framerate 8 -pattern_type glob -i 'frames/*.png' -c:v libx264 -pix_fmt yuv420p out.mp4
ffmpeg -y -i out.mp4 \
    -vf "fps=8,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    -loop 0 out.gif