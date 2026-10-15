# Auth

Local email/password (`has_secure_password`) and Google OAuth (omniauth), plus an admin-gated
approval workflow so a new account can't use the app until a human says it's okay.

## Signing up

Two ways to get an account:

- **Self-service**: `/signup` (`RegistrationsController`) or "Sign in with Google" on `/login`
  (which creates a `User` on first login if no existing account matches the email). Either way
  the new user starts in `status: pending` (the `status` column's DB default) and is logged in
  immediately, landing on the pending-approval page below until an admin approves them.
- **Admin-created**: `Admin::UsersController#create` (the "Add User" button on `/admin/users`)
  sets `status: :approved` directly — an admin creating an account is itself the approval.

## `status` enum

`User#status` is an integer enum: `pending` (0, the default), `approved` (1), `denied` (2), backed
by a DB index (`index_users_on_status`) since `Admin::UsersController#index`'s search/pagination
scans it indirectly via `order(:name)` combined with per-row status checks, and `approve`/`deny`/
`unapprove` all look it up by id. This replaced an earlier plain `approved` boolean
(`db/migrate/..._convert_user_approved_to_status_enum.rb`) because "denied" needed to be
distinguishable from "hasn't been reviewed yet" — both used to just be `approved: false`.

`ApplicationController#require_approval` branches on it: `approved?` passes through,
`denied?` renders `shared/denied`, anything else (`pending?`) renders `shared/pending_approval`.

## Admin review (`/admin/users`)

- **Pending**: Approve or Deny.
- **Denied**: Approve (a denial isn't final).
- **Approved**: "Undo Approve" (`unapprove` action, resets to `pending`) — not shown for the
  current admin's own row, since status is checked by `require_approval` on every request and an
  admin undoing their own approval would immediately lock them out of the admin panel they're
  using to do it.
- **An admin's status can't be changed at all** (`approve`/`deny`/`unapprove` all return early
  with an alert when `user.admin?`), whether it's the current admin or a different one. This
  guard is server-side (not just a hidden button), since `admin/deny` or `admin/unapprove` could
  otherwise be hit directly.

The index itself is a single search + pagination view (`Admin::UsersController#index`, via the
`pagy` gem — `ApplicationController` includes `Pagy::Backend`, `ApplicationHelper` includes
`Pagy::Frontend`), not three unbounded lists — `?q=` does an `ILIKE` match against name or email.
This mirrors `../wheels`' own `admin/users#index`.

## Editing a user (`Admin::UsersController#edit`/`#update`)

Reuses `admin/users/_form.html.haml`, the same partial `new` uses. The password field's behavior
depends on `user.persisted?`:

- **New user**: "Password" + a required confirmation field.
- **Existing user**: "New password (leave blank to keep current)", no confirmation field, and
  `update` strips `:password`/`:password_confirmation` from the permitted params entirely when
  the submitted password is blank — otherwise an edit that doesn't touch the password would wipe
  it (`has_secure_password` treats a blank `password=` as "clear the digest", not "no change").
  This is the same pattern `../wheels`' own user edit form uses.

`status` is intentionally not editable from this form — it only changes via approve/deny/unapprove.
