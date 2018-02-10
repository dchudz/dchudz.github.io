---
layout: post
category: posts
draft: true
title: Git First-Parent-- Have your messy history and eat it too
---

(Draft)

## Intro

The 1st thing I encountered learning about git: there's a lot of conflict about whether it's important to keep a "clean" git history by squashing, rebasing instead of merging, etc.

In favor of 'cleanliness' [^1]:

- `git log` shows the higher-level history most people will care more about
- the one-to-one relationship between code-reviewed changes and commits
- it's quicker to identify where problems were introduced
- it's safer to revert (and easier to use tools like `git bisect`) because every commit on `master` should be good (often very important when quickly fixing production problems)

Against:

- just committing often and merging normally is much easier for newbies, and somewhat easier for everyone
- messing with history complicates everything
- more history is useful
- code review: there should be a commit for addressing comments
- code review, what changed
- squashing complicates various operations (like branching off a branch that's under review to work on something new that depends on it)[^2]

Around then, I came across a blog post (sorry, can't find it now) arguing that this disagreement is stupid and git is stupid because the clean-history group is having a problem with *data display*, not *data collection*. The problem isn't the extra information (messy commits): it's that the information isn't displayed in a way that shows them what they're interested in (larger changes that are code-reviewed, pass the tests, etc.).

The post struck a chord with me, but didn't suggest any solution so I got grumpy and otherwise ignored it.

Now I know about `--first-parent` (because my last company used it) which gets you the best of all worlds:

## First Parent

When `git log` encounters a merge commit, it normally follows the history backwards through both parents. 

For example, 

[^3]]

# 

So then [^4]

```
> git log
7e066dba825c1d69afba3f85224d0b1105cf6f6d Merge branch 'feature-branch'
29061db581422e881da5da82e240c81fdd1b621e 2nd commit on master
04bb2b70e652e180147478159a265c13f5e34205 2nd commit on feature
0d1561a2b48129ef80482f5b63abe80290d8686c 1st commit on feature
725034cce8087fc133613b3461d7286e276ccb27 1st commit on master
```


```
> git log --format=oneline --first-parent
7e066dba825c1d69afba3f85224d0b1105cf6f6d Merge branch 'feature-branch'
29061db581422e881da5da82e240c81fdd1b621e 2nd commit on master
725034cce8087fc133613b3461d7286e276ccb27 1st commit on master
```


```
> git blame feature
0d1561a2 (David Chudzicki 2018-02-10 14:21:43 -0500 1) cats
04bb2b70 (David Chudzicki 2018-02-10 14:22:32 -0500 2) dogs
```

```
> git blame feature --first-parent
7e066dba (David Chudzicki 2018-02-10 14:23:43 -0500 1) cats
7e066dba (David Chudzicki 2018-02-10 14:23:43 -0500 2) dogs
```

```
git rev-list 72503..7e066
7e066dba825c1d69afba3f85224d0b1105cf6f6d
29061db581422e881da5da82e240c81fdd1b621e
04bb2b70e652e180147478159a265c13f5e34205
0d1561a2b48129ef80482f5b63abe80290d8686c
```

```
git rev-list 72503..7e066 --first-parent
7e066dba825c1d69afba3f85224d0b1105cf6f6d
29061db581422e881da5da82e240c81fdd1b621e
```


## Advice

If you're using Github, it will by default put the the pull request title in the 2nd line of the merge commit's message.

  - it's nice that it's there at all
  - it's not so nice to have the 1st like be the less meaningful `Merge pull request #<number> from <branch-name>`

At the company where I was introduced to `--first-parent`, I think we used a custom script that made more useful topline merge commit messages. But I don't expect everyone to do that, so I'm not sure what to suggest.

If you like this workflow, I do suggest that you enforce **no fast-forward commit merges**. A "fast-forward" merge can happen when two branches haven't diverged at all so you don't really need a merge at all. With this workflow, you should avoid that because then the individual commits from your feature branch would show up in `git log --first parent`. You should merge with `--no-ff`, which is Github's default merge strategy. 

Where I work now, if you merge using our (internal) code review tool, the default commit message for the merge will have its top line be the title of your pull request. That's great for this workflow, because a good commit message for posterity is the same as a good title for reviewers. Just by looking at the title of your request, reviewers are reviewing the commit message.









for squashing:


against:


https://github.com/AgileVentures/AgileVentures/issues/7


[^1]: If it weren't for the `--first-parent` option discussed in this post, I would find these considerations decisive.

[^2]: If you make changes to the 1st branch (based on code review feedback) and squash them into the previous commit, it can be tricky to merge those changes into your 2nd feature branch.

[^3]:
```
git init
touch hi
git add hi
git commit -m '1st commit on master'
git checkout -b feature-branch
echo "cats" > feature
git add feature
git commit -m '1st commit on feature'
echo 'dogs' >> feature
git add feature
git commit -m '2nd commit on feature'
git checkout master
echo "hello" >> "hi"
git commit -am "2nd commit on master"
git merge feature-branch
```

[^4]: My log is showing up consisely formatted because I did `git config format.pretty "format:%h%x09%an%x09%ad%x09%s"`