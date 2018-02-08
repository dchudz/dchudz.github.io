


display vs. data collection


no fast-forward merges

log

blame

git blame hi.py --first-parent
323bc5c1 (David Chudzicki 2018-02-07 19:20:43 -0500 1) A = 1
323bc5c1 (David Chudzicki 2018-02-07 19:20:43 -0500 2) B = 2
(master) /Users/davidchudzicki/temp/a $
git blame hi.py
d31c5e3a (David Chudzicki 2018-02-07 19:20:15 -0500 1) A = 1
d071a206 (David Chudzicki 2018-02-07 19:20:30 -0500 2) B = 2

workarounds for bisect: https://stackoverflow.com/questions/5638211/how-do-you-get-git-bisect-to-ignore-merged-branches

other tools

github

commit message is title being reviewed




benefits of clean history:
- easier birds eye view
- no commits should be broken
- identify where problems started and safely revert


benefits of dirty history:
- screwing with history complicates everything

- more history is useful
- more consistent with "push early and often"
- squashing loses information
- code review: there should be a commit for addressing comments
- 

Reflog