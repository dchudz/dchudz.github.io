---
layout: post
category: posts
draft: false
title: Git First-Parent: Have your messy history and eat it too
---

The 1st thing I encountered learning about git: some people care a lot about a "clean git history" and other people can't be bothered to "squash" commits, rebase-instead-of-merge, etc. (and don't like "changing history").

The 2nd was a blog post (sorry, can't find it now) arguing that this disagreement is stupid and git is stupid because the clean-history group is having a problem with *data display*, not *data collection*. The problem isn't the extra information (messy commits): it's that the information isn't displayed in a way that shows them what they're interested in (larger changes that are code-reviewed, pass the tests, etc.).

The post struck a chord with me, but didn't suggest any solution so I got grumpy and otherwise ignored it.

Now I know about `--first-parent` (because my last company used it) which gets you the best of all worlds:

When `git log` encounters a merge commit, it normally follows the history backwards through both 


- `git ... --first-parent` 


# 



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
