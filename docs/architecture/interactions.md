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
"Log New Interaction" button above the admin-only section.

## Not yet built

- Looking an interaction up against an existing `ServicePlan`.
