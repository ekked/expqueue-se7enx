# Scheduling

## Classes

`[QueueSettings] Classes[]` lists the priority classes; each has `[QueueClass_<name>]`:

| Setting | Meaning | Defaults (interactive, editorial, chain, translation_patch, translation_full, bulk, system) |
|---|---|---|
| `Weight` | share of the starts while several classes have ready jobs | 50, 30, 15, 10, 5, 4, 10 |
| `MaxRunning` | jobs of the class running at once across all workers (0 = none) | 4, 4, 3, 3, 3, 2, 1 |
| `MinShare` | guaranteed fraction of the starts while it has ready jobs | 0, 0.10, 0.05, 0.05, 0.05, 0.05, 0 |
| `DefaultPriority` | 0..100 when the producer gives none | 50 |
| `Reserved` | served before every other class; not part of the fair share | system only |
| `MaxAttempts` | attempts of its jobs when type and producer give none | 0 (DefaultMaxAttempts) |

## A dispatch round

1. **Eligible classes**: a ready job (run_after passed), not paused, below `MaxRunning`, in the worker's `--class`.
2. **Their order**:
   1. reserved classes;
   2. **starvation guard**: a class whose oldest ready job waited longer than `StarvationSeconds`, longest first;
   3. **MinShare**: a class that got less than its MinShare of the starts of the last `MinShareWindow` seconds (once
      at least 10 started), largest deficit first;
   4. **stride scheduling**: the smallest pass first. The chosen class's pass grows by `100000 / Weight`; the passes
      are stored in `expqueue_class`, so the shares hold across all workers. An idle class comes back at the current
      virtual time (the row `*`), not with credit for its idle time.
3. **Within the class**: jobs that waited longer than `StarvationSeconds` first (longest first; aging alone is capped
   by `AgingMax`), then the highest effective priority `priority + min(AgingMax, waited / AgingStep)`, then the
   longest waiting. Up to `CandidateLimit` candidates: the highest priorities and the longest waiting are both read.
4. **Skipped** candidates: resource paused, cooling down or full; group paused; user or site at
   `MaxRunningPerUser` / `MaxRunningPerSite`.
5. **The lease**: compare-and-set; a lost race tries the next candidate.

With the default weights and three busy classes editorial / translation_full / bulk, the starts split about
30 : 5 : 4 (77 % / 13 % / 10 %); MinShare keeps translation_full and bulk at no less than 5 % each, and once the
editorial jobs are gone the others get every slot.

## Quotas (`[QueueQuotas]`, 0 = none)

- `MaxQueuedPerUser`, `MaxQueuedPerSite`: enqueue refuses (expQueueException) beyond that many waiting jobs.
- `MaxRunningPerUser`, `MaxRunningPerSite`: the scheduler starts no more for that user or site.

The site of a job is the producer's `site` option, else `[QueueSettings] SiteName`, else site.ini SiteName.

## Resources

A job names a resource (`resource` option, the type's `Resource=`, or a rule). At most the current limit of the
resource runs at once. `[QueueResource_<key>]` (defaults in `[ResourceSettings]`): `MaxConcurrent`, `MinConcurrent`,
`Adaptive`, `IncreaseAfter`, `LowWater`, `DefaultCooldown`. With `Adaptive=enabled`, what handlers report with
`$context->rateLimit()` steers it:

| Hint | Effect |
|---|---|
| status 429 / 529, or `retry_after` | limit halved (not below MinConcurrent); cooldown for retry-after (or until `reset_at`, else DefaultCooldown) |
| `remaining_requests` <= LowWater | limit drops to MinConcurrent; at 0 a cooldown until `reset_at` |
| status 401 / 403 | the resource is paused (credentials or billing need a person) |
| `IncreaseAfter` successes in a row | limit + 1 up to MaxConcurrent |

## Rules (`[QueueRules] Rules[]`)

The first rule that matches sets `Class`, `Priority`, `Resource` and/or `MaxAttempts` at enqueue time. Match on
`Type` (a pattern with `*`), `MatchResource` (a pattern), `Site` and `Tag` (one of the producer's `tags`). What the
producer passes explicitly still wins.

```ini
[QueueRules]
Rules[]=news_fast
[QueueRule_news_fast]
Type=ai.translate.*
Tag=section:news
Class=editorial
Priority=70
```

## Retries

`max( retry_after, min( MaxBackoff, RetryBase * 2^(attempt-1) ) * random(0.5 .. 1.0) )` seconds, per type
overridable (`RetryBase=`, `MaxBackoff=` in `[JobType_<type>]`). After `max_attempts` the job goes to the dead letter.

## Measured (sandbox, SQLite, 2026-10-11)

See [changelog/0.1.0.md](changelog/0.1.0.md) for the scale and fairness runs.
