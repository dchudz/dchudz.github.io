---
layout: post
category: posts
draft: true
title: Git First-Parent-- Have your messy history and eat it too
---

(Draft)

## Intro

The first thing I encountered learning about git: there's a lot of conflict about whether it's important to keep a "clean" git history by squashing, rebasing instead of merging, etc.

In favor of 'cleanliness' [^1]:

- `git log` shows the higher-level history most people will care more about
- the one-to-one relationship between code-reviewed changes and commits is nice
- it's quicker to identify where problems were introduced
- ... and safer to fix those problems by deploying an earlier commit (and easier to use tools like `git bisect`) because every commit in `master`'s history should be good (this is often very important when quickly fixing production problems)

Against:

- just committing often and merging normally is much easier for newbies, and somewhat easier for everyone
- messing with history complicates everything
- more history is useful, e.g. for cherry-picking into another branch, or understanding what someone was thinking when they wrote something
- changing history makes code review much harder (which version was this comment left on? has the author changed anything since I reviewed this?)[^2]
- squashing complicates various operations (like branching off a branch that's under review to work on something new that depends on it)[^3]

Then I came across a blog post (sorry, can't find it now) arguing that this disagreement is stupid and git is stupid because the clean-history side is having a problem with *data display*, not *data collection*. The problem isn't the extra information (messy commits): it's that the information isn't displayed in a way that shows them what they're interested in (larger changes that are code-reviewed).

The post struck a chord with me, but didn't suggest any solution so it just made me grumpy and otherwise I ignored it.

Now I know about `--first-parent` (because my last company used it) which gets you the best of all worlds:

## First Parent

When `git log` encounters a merge commit, it normally follows the history backwards through both parents. 

For example, after branching off master, adding some commits, and merging into master[^4], we might see[^5]:

```
> git log
7e066db David Chudzicki Sat Feb 10 14:23:43 2018 -0500  Merge branch 'feature-branch'
29061db David Chudzicki Sat Feb 10 14:23:30 2018 -0500  2nd commit on master
04bb2b7 David Chudzicki Sat Feb 10 14:22:32 2018 -0500  2nd commit on feature
0d1561a David Chudzicki Sat Feb 10 14:21:43 2018 -0500  first commit on feature
725034c David Chudzicki Sat Feb 10 14:21:23 2018 -0500  first commit on master
```

But if we say `--first-parent`, `git log` will ignore all of the history in the second parent of a merge commit:

```
> git log --first-parent
7e066db David Chudzicki Sat Feb 10 14:23:43 2018 -0500  Merge branch 'feature-branch'
29061db David Chudzicki Sat Feb 10 14:23:30 2018 -0500  2nd commit on master
725034c David Chudzicki Sat Feb 10 14:21:23 2018 -0500  first commit on master
```

You can also use `--first-parent` with other git commands, like `blame` and `rev-list`. By default we see the two individual commits in the file introduced by the merge:

```
> git blame feature
0d1561a2 (David Chudzicki 2018-02-10 14:21:43 -0500 1) cats
04bb2b70 (David Chudzicki 2018-02-10 14:22:32 -0500 2) dogs
```

... but with `--first-parent` we only see the merge commit:

```
> git blame feature --first-parent
7e066dba (David Chudzicki 2018-02-10 14:23:43 -0500 1) cats
7e066dba (David Chudzicki 2018-02-10 14:23:43 -0500 2) dogs
```


## Don't fast forward

By default, git uses a "fast-forward" when the two branches haven't diverged at all so you don't really need a merge at all. The new commits are just applied as-is with no merge. If you're hoping to get a clean history from `--first-parent`, you should avoid that because then the individual commits from your feature branch would show up in `git log --first parent`. You should only merge with the  `--no-ff` option, which is Github's default merge strategy. 

## Give your merge commits a good top-line message

Merge commits should always have nice messages summarizing, in the first line, what was introduced/changed.

If you're using Github, it will by default put the the pull request title in the 2nd line of the merge commit's message (and something like `Merge pull request #<number> from <username>/<branch>` in the first line, which is not as good as putting it in the first line.

At the company where I was introduced to `--first-parent`, I think we used a custom script that made more useful topline merge commit messages based on pull request titles. But I don't expect everyone to do that, so I'm not sure what to suggest. Unfortunately, this alone might be enough reason to use the squash option instead, if you're using Github for your merges.

Where I work now, if you merge using our (internal) code review tool, the default commit message for the merge will have its top line be the title of your pull request. That's great for this workflow, because a good commit message for posterity is the same as a good title for reviewers. Just by looking at the title of your request, reviewers are reviewing the commit message.

## I hope tooling gets better

The workflow I've described here seems good enough that I would suggest it for my team. But not all tools will nicely support `--first-parent`. For example:

- most code reviewers (e.g. Github's, or my current company's internal one) will show you a list of commits on a branch, but won't let you filter that by `--first-parent`
- some editors (e.g. PyCharm) will annotate lines with git history (like `git blame`), but often won't let you customize this by giving option like `--first-parent`


[^1]: If it weren't for the `--first-parent` option discussed in this post, I would find these considerations decisive.

[^2]: If you use Github's "Squash and merge" feature, this won't be a problem: You can just commit freely as you go and squash/merge after code review is all over. Other teams I've been on asked people to squash before posting a pull request, but had a strong norm against changing history once anyone else has seen the code. My current company's code review tool supports "revisions", so it's possible to see what's changed even if every new version is completely squashed. But that means we're using this internal tool to track history, which is a job much better suited for git.

[^3]: If you make changes to the first branch (based on code review feedback) and squash them into the previous commit, it can be tricky to merge those changes into your 2nd feature branch.

[^4]: In an empty directory, you can do this to reproduce my git history: `git init && touch hi && git add hi && git commit -m 'first commit on master' && git checkout -b feature-branch && echo "cats" > feature && git add feature && git commit -m 'first commit on feature' && echo 'dogs' >> feature && git add feature && git commit -m '2nd commit on feature' && git checkout master && echo "hello" >> "hi" && git commit -am "2nd commit on master" && git merge feature-branch`

[^5]: My log is showing up consisely formatted with one commit per line because I did `git config format.pretty "format:%h%x09%an%x09%ad%x09%s"`