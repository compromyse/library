# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What Library does

Library helps caseworkers track client interactions and the service plans that come out of them.

Each **interaction** records the observed characteristics of the person (approximate age, gender), the issues raised, and for each issue a primary need (housing, food, insurance, mental health, medical, other) plus a description of what happened. An interaction can be looked up against an existing service plan, and each one records roughly how long it took.

A **service plan** is built around a client profile (name, contact info, date of first contact) with background notes. It accumulates service plan interactions over time, each with: a date, the need being addressed, the action taken or referral made, a point person (defaults to whoever is logging it, but can be searched among other users or typed in as a raw string if that person doesn't exist in the system), and a status — split into ongoing and completed, with notes for either.

Target audience: caseworkers logging interactions quickly, often on a phone, sometimes mid-conversation with a client. The UI must stay simple and low-friction — see `DESIGN.md`.

### Future considerations

- Models, auth, and the interaction/service-plan views described above are not built yet — only the UI scaffolding (layout, styling, Haml/Tailwind setup) exists so far.

## Quick reference

- UI design rules: `DESIGN.md`
- Commit policy: see Commits section below
- Testing policy: see Testing section below
- Updating docs: see Documentation section below

## Commits

Do not include a Co-Authored-By line in commit messages.

Write commit messages with a subject line and a body. The body should explain what changed, why, and what the tests cover — two to three sentences minimum. One-line subjects alone are not enough.

## Testing

Every new feature and every change to existing behaviour must have tests before committing. Run the full suite with `PGDATA=$(pwd)/pgdata rails test` and confirm it passes. Do not commit with failing or missing tests.

## Documentation

When making changes, update the relevant `docs/` file(s) before committing. Keep docs current — stale docs are worse than none.

## Stack

Rails 8.1 · PostgreSQL (local Unix socket at `pgdata/`) · HAML · Tailwind CSS v4 · Nix flakes

Always set `PGDATA=$(pwd)/pgdata` when running Rails commands. Run the app with `bin/dev`.
