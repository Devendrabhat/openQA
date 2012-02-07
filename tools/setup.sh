#!/bin/bash

mkdir -p perl testresults testrun-manual testrun-cron factory/iso video backlog
(cd perl ; git clone git://gitorious.org/os-autoinst/os-autoinst.git autoinst )

echo "au BufRead,BufNewFile *.mt se syntax=php" >> ~/.vimrc

# part of the install needs to be done as root
sudo tools/rootsetup.sh

