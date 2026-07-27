# Case Study: from self-service dashboards to an Analytics Engineering project

## Context

In my day-to-day work as a Data Analyst, I'm responsible for part of the
dbt modeling and for building self-service dashboards consumed by
product, marketing and operations teams. One of the domains I support is
product engagement analytics (sessions, duration, bounce rate), used to
monitor traffic health and spot changes in user behavior.

## The original problem

The product team needed to answer recurring questions without depending
on an analyst for every query:

- How is average session duration trending?
- What's the rate of very short sessions (a proxy for UX issues or bot traffic)?
- Which time windows have the weakest traffic (useful for planning
  maintenance windows and deploys)?

## Modeling decisions

- **Staging isolated from the raw source**: the staging layer exists
  precisely so that if the source of events changes (e.g. switching
  tracking tools), only one place in the project needs to change.
- **Explicit grain per mart**: instead of one overly-wide "sessions"
  table, I split it into `fct_sessions_daily` (grain: day) and
  `fct_sessions_hourly` (grain: day of week × hour) — each serves a
  different business question and avoids the dashboard having to
  aggregate an event-grain table on the fly.
- **Bounce defined in staging, not in the mart**: the definition of "what
  counts as a bounced session" is a stable rule (it doesn't change per
  mart), so flagging it already in staging avoids reimplementing the same
  logic in multiple places — a DRY (`Don't Repeat Yourself`) principle
  that applies to analytics SQL just as much as to application code.

## What changed in this public version

This repository uses a generic domain (sessions on a fictional site) and
100% synthetic data, but faithfully replicates the layered architecture,
testing conventions and aggregation logic used in the real job. No table,
column name, value or business-specific rule from the employer was
reused — the similarity is structural (how to organize staging → marts,
how to test, how to document), not literal.

## Project roadmap (public)

- [x] `site_kpis` — engagement and traffic (Week 1)
- [ ] `cohort_retention` — retention by acquisition cohort (Week 2)
- [ ] `payments_funnel` — transaction conversion funnel (Week 3)
- [ ] `customer_segmentation` — customer value segmentation (Week 4)
- [ ] Dashboard published on Evidence.dev
- [ ] CI with GitHub Actions running `dbt build` on every push