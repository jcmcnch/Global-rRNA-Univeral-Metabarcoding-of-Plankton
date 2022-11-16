#!/bin/bash -i

#remove empty files
find 220815_demuxd_MG/ -size  0 -print0 | xargs -0 rm -- 2> /dev/null
