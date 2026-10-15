# Interactions

A caseworker logs an **interaction** right after talking to a client, often on a phone. It
records observed characteristics (approximate age, gender), one or more **issues** raised during
the conversation, and roughly how long the interaction took.

## Model

- `Interaction` has many `Issue`s (`dependent: :destroy`), built through nested attributes.
  Requires `age`, `gender`, `estimated_time`, and at least one issue.
- `Issue` belongs to an `Interaction`. Requires a `primary_need` and an
  `interaction_description`. When `primary_need` is `other`, `primary_need_other_detail` is also
  required.
- `primary_need`'s enum lives in the `HasPrimaryNeed` concern (`app/models/concerns/has_primary_need.rb`)
  so it can be shared with `ServicePlanInteraction`, which tracks the same categories.

Dropdown option labels are generated with `.humanize` on the enum keys directly in the view —
there is no separate label/constant map to keep in sync.

## Form

`app/views/interactions/new.html.haml` renders a single `form_with` for `Interaction` with nested
`fields_for :issues`. Issue rows are added/removed client-side without a page reload:

- `app/javascript/controllers/issues_form_controller.js` clones a `<template>` block
  (`#issue-row-template`) and appends it to the row list, substituting a fresh index for each new
  row.
- `app/javascript/controllers/primary_need_controller.js` toggles the "if other, please specify"
  field for a single issue row, showing it only when that row's `primary_need` select is set to
  `other`. The field's initial visibility is also rendered correctly server-side (via
  `Issue#other?`) so it doesn't flash on load or break without JavaScript.

`InteractionsController#create` permits `age`, `gender`, `estimated_time`, and
`issues_attributes: [:primary_need, :primary_need_other_detail, :interaction_description]`.

## Access

Logging an interaction requires an authenticated, approved user (see `ApplicationController`) but
not admin rights — any caseworker can log one. The dashboard (`home#index`) surfaces a prominent
"Log Interaction" button.

## Dashboard: today's interactions

`HomeController#index` loads every `Interaction` created today (`Time.current.all_day`, most
recent first) into `@todays_interactions` and renders it as a table above the "Log Interaction"
button. Only the first 5 rows are visible; the rest are rendered with a `hidden` class and
revealed in place by `app/javascript/controllers/expandable_controller.js` when the caseworker
clicks "Show all (N)" (N is the total count for the day). This is a plain CSS-class toggle, not a
second request — all of today's interactions are already in the response.

Because "today" is evaluated against `Time.zone`, `config.application.rb` sets
`config.time_zone = "Eastern Time (US & Canada)"` — without it Rails defaults to UTC, and an
interaction logged in the evening would silently fall into the next UTC calendar day and vanish
from the dashboard. `interactions.created_at` has a database index to back that `WHERE` + `ORDER
BY` query.

### Expanding a row instead of a show page

Each summary row has a paired detail `<tr>` (`colspan`-ed, initially `hidden`) containing an empty
`<turbo-frame>` with the interaction's `primary_need`/detail/description for every issue — a
lighter alternative to a dedicated show page. The frame's `src` is intentionally left unset in the
server-rendered HTML (only stashed in `data-src`) so a day's worth of issues is never eager-loaded
into the dashboard response. `app/javascript/controllers/row_details_controller.js` toggles the
detail row's visibility on click and, the first time a row opens, copies `data-src` onto the
frame's real `src` attribute, which makes Turbo fetch `InteractionsController#show` (rendered with
`layout: false`, `includes(:issues)` to avoid an N+1 there) and fill the frame in place. Later
clicks just toggle visibility — the frame keeps its already-fetched content.

## Not yet built

- Looking an interaction up against an existing `ServicePlan`.
