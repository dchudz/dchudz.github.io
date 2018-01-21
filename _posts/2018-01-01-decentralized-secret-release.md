---
layout: post
category: posts
draft: true
title: Decentralized Triggered Secret Release
---

## Intro

Have you ever had to confront a villain with your discoveries, knowing that unless you take precautions first they might just kill you? Or gone on a dangerous adventure, wanting to keep the details secret until you come back (or unless you don't)? Or wanted your passwords to be shared with a friend if you became long-term unavailable?

I haven't either, but who knows.

These problems can be solved with a single trusted secret-holder: You give your secret to someone, and tell them not to look at it or share it until some condition is triggered. (The trigger might be e.g. failure to receive an I'm-still-here message from you every week.)

But that's error-prone. Even if you 100% trust their good intentions, it's still easy for a single point of failure to make a mistake (in either direction: they might be compromised and release the secret too early, or they might disappear or lose the secret).

## Decentralizing

Can we achieve the same kind of triggered release without trusting a single interediary? I think so, and here's the process I'm imagining:

1. The *secret-sharer* gives (different) data to each of the *secret-holders* such that some subset of them could reconstruct the secret
2. The secret-sharer makes public a condition under which the secret-holders should release the secret publicly
3. If the condition is met, the secret-holders publish their parts of the secret.
4. Now anyone[^1] can reconstruct the secret.

[^1]: Note that this same process can be used for releasing a secret to a single secret recipient rather than the public: First the secret-sharer would encrypt the secret with the recipient's public key, and then the rest of the process is followed as usual.)

There are some incentives we need to get right in order for this to work:

- each secret-holder should be rewarded for participating in the process (regardless of whether the condition is triggered)
- each secret-holder should be punished if they release their part of the secret too early
- each secret-holder should be punished if they fail to release their part of the secret after the condition is triggered
- each secret-holder should be able to trust that no one else knows their part of the secret 

The last condition rules out a straightforward application of [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing). We can't have the secret-sharer compute the secret-holders' shares of the secret, since then the secret-holders couldn't trust that they won't be wrongly punished (if the secret-holder accidentally or purposefully released some or all of the shares).

The punishments must be consist of significant losses for the secret-holders (not just failure to get paid), because a secret-holder who doesn't follow the rules undermines the integrity of the whole system. We'll require deposits which they lose if the punishment conditions are triggered.

I think we can use Ethereum to achieve these incentives. This procedure will require all `$N$` secret-holders' for the secret-reconstruction phase, but I think we can modify it later so only a proper subset of the `$N$` are needed:

(For convenience, let's say `$p_0$` is the secret-sharer, and `$p_1$` through `$p_n$` are the secret-holders.)

1. The secret-holders make a deposit to the contract.
2. Each secret-holder `$p_i$` (`$1 \leq i \leq N$`) generates a random string `$s_i$` of the same length as the secret.
3. For convenience, let's say the secret is $s_0$.
4. Everyone sends the hash of their $s_i$ to the contract.
5. Then everyone computes the sum `S = $\sum_{i=0}^n s_i$` without revealing anyone's `$s_i$` (see below for more on how to do this). `$S$` is now public, but doesn't reveal anything about the secret.
6. If the contract's "release" condition is triggered, then the secret-sharers each release $s_o$. 

## Contract

This is pretty rough, but here's a basic idea of the kinds of functions the constract would have to support this flow:

- (constructor) - should store the addresses of the secret-holders and secret-sharer; the contract should be created with enough funds to pay the secret-holders for their participation
- `store_hash($p_i$)` - each `$p_i$` calls this with the `hash($s_i$)`, which is stored.
- something to decide when the hash-collection phase is over
- `should_release()` - this private function determines whether it's time to release the secret, and can be written however we want - maybe it's based on the date, or based on another function `ping` not receiving a call from the secret-holder for a certain period of time; I'll assume that after 1 year from contract creation, `should_release()` is guaranteed to return `True`
- `punish_for_release($p_i$, $s_i$)` (only callable before `should_release()` is true) - anyone holding `s_i` can send `$p_i, s_i$` to cause `$p_i$` to lose their deposit for releasing too early (and receive a small reward for their trouble)
- `release($s_i$)` - (only callable after `should_release()` is true) `$p_i$` sends `s_i`, we confirm that its hash matches the stored hash, and `$p_i$` receives their deposit payment, plus their payment for participating


## How to Add[^2]

[^2]: This isn't original to me.

How do we compute the sum `S = $\sum_{i=0}^n s_i$` without revealing anyone's `$s_i$`? Here's one way:

1. Each `$p_i$` generates a random `$r_{ij}$` to send to each `$p_j$`.
2. Each `$p_i$` now knows `$r_{ij}$` and `$r_{ji}$` for all other players `$j$`.
3. Each `$p_i$` computes and publishes `$s_i + \sum_{j=0}^n r_ij + \sum_{j=0}^n r_ij$`.
4. Everyone can add up the numbers in (3) to obtain `$S$`.

## What about cheaters?

What if someone provides the wrong input to the sum computation, one they don't even store? Then the secret won't be recoverable, but we can't punish them for this or even know that they're behaving inconsistently (publishing the hash of a different `$s_i$` than the one they used in the sum).

I can think of two ways to address this risk:

We could do a random number of "trial runs" first, where the secret-sharer uses a random `$s_0$` instead of their secret. Only the secret-sharer will know whether we're in a trial-run. After the secret-sharer announces "that was a trial run", everyone (including the secret sharer) reveals their `$s_i$`. If the sum is `$S$` and the hashes match up, then everyone followed the protocol. If everyone followed the protocol in a bunch of trial runs (and they don't know the real one is coming), then they'll probably be following it in the real run too.

Alternatively, we could switch to something fancier. A lot has been written about [secure multiparty computation](https://en.wikipedia.org/wiki/Secure_multi-party_computation), including with error-detection.

## M of N

As described, this scheme requires all secret-holders to follow the protocol for the secret release. This means that even a single one could hold out for extra payment (or just lose their key).

We really want the secret to be reconstructable from just a smaller subset of the secret-holders.

I think it's probably possible to do this using polynomials like in [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) - but a very inefficient (probably too inefficient) way would be to repeat the procedure for each subset of `$M$` secret-holders.

## Amortize 

It might make sense for a secret-holder to be able to use the same deposit for multiple different people's secrets. The benefit would be having a larger deposit overall, so perhaps greater security. The drawback would be that once a secret-holder has lost their deposit for revealing one `$s_i$` too early, they have no incentive to keep the others secret or reveal them at the right time.


## Time limits

The scheme requires the secret to be released within some fixed time period, because the depositors need to get their deposit back at some point.

Alternatively, we could set things up so that the secret-sharing has the option to pay the holders for each additional time period during which they don't release the secret. As with the originl payment, the continuing would have to be at least a bit higher than the interest the secret-holders could receive on their deposit if they hadn't made it.

The secret-holders would not have the option to withdraw their deposit unless the secret-sharer stops paying.
