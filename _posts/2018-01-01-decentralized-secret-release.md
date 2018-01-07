---
layout: post
category: posts
draft: false
title: Decentralized Triggered Secret Release
---

Have you ever had to confront a villain with your discoveries, knowing that unless you take precautions they might just kill you? Or on a more mundane level, wanted your passwords to be shared with a loved one if you died?

These problems can be solved with a single trusted secret-holder: You give your secret to someone, and tell them not to look at it or share it until some condition is triggered. (The trigger might be e.g. failure to receive an I'm-still-here message from you every week.)

But trusting a single secret-holder is error-prone. Even if you 100% trust their good intentions, it's easy for a single point of failure to make a mistake (in either direction: they might be compromised and release the secret too early, or they might disappear or lose the secret).

Can we achieve the same kind of 


the Ethereum blockchain/computer/currency 


hi

Goals:


The secret can't be released early unless the secret-holders collude.

1. Secret-holders receive a small reward for releasing their portion of the secret when release is triggered.
2. Each secret-holder receives a large punishment if their portion of the secret is released early.

`$a_5$`
$a_5$

In practice, making an inference at `$X_1 = 0$, $X_2 = 1$` would be pretty hopeless. 

## N of M

As described, this scheme requires all secret-holders to follow the protocol for the secret release. This means that even a single one could hold out for extra payment (or just lose their key).

We really want the secret to be reconstructable from just a smaller subset of the secret-holders.

One (very inefficient) [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing).