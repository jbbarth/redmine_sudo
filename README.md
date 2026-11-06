# Redmine Sudo plugin

Like `sudo` on Unix, this plugin lets the people who administer a Redmine
instance work as normal users most of the time and reclaim admin rights only
when they need them. Admin rights are claimed in one click, live in the
browser session alone, and expire on their own.

To make the current status obvious, the plugin can inject CSS that only applies
while you are acting as admin (for example, turning the header red).

## Screenshots

Acting as a standard user:

![Standard user](http://jbbarth.com/screenshots/redmine_sudo_1.png)

Click the link to become administrator:

![Administrator](http://jbbarth.com/screenshots/redmine_sudo_2.png)

The admin section lets you set the link titles and the admin-only CSS:

![Settings](http://jbbarth.com/screenshots/redmine_sudo_3.png)

## How it works

There are two independent columns on `users`, edited as two separate
checkboxes ("Administrator" and "Sudoer") on the Users admin form. Checking or
unchecking one never affects the other.

| Column   | Meaning                             | Web UI                           | REST API, rake, jobs |
| -------- | ----------------------------------- | -------------------------------- | -------------------- |
| `admin`  | Permanently an administrator        | Always admin, no toggle offered  | Admin                |
| `sudoer` | May elevate for one browser session | Normal user until *Become Admin* | Normal user          |

A sudoer is a normal user at rest, exactly like a Unix user listed in
`/etc/sudoers` is not root until they run `sudo`. The last column covers every
context that is not an interactive browser session: REST API keys, OAuth
bearer tokens, atom feed keys, HTTP Basic, rake tasks and background jobs.

### Elevation is session state, never database state

`User#admin?` is overridden to return true when either the `admin` column is
set, or the user elevated **in the session that is making this very request**:

```ruby
def admin?
  return true if super

  @sudo_session_admin == true && !authorized_by_oauth?
end
```

`@sudo_session_admin` is set by a `user_setup` override (once the user is
resolved, whichever lookup resolved them), on the `User` instance built for
the current request only, and only when all of the
following hold:

1. the request was authenticated by the session cookie (`session[:user_id]`
   matches the user — an API key or atom key travelling alongside a cookie is
   not enough);
2. that session recorded an elevation for this same user
   (`session[:sudo_admin_user_id]`);
3. the session is not a `redmine_pretend` impersonation
   (`session[:real_user_id]` is blank), so an impersonated account never
   inherits the impersonator's elevation;
4. Redmine core's sudo timestamp is still valid (see the timeout section
   below), unless core sudo mode is disabled entirely.

Three properties follow directly from this design:

- **No request ever writes the `admin` column.** Becoming admin, dropping
  admin and expiring all only touch the session.
- **Sessions are isolated.** Elevating, dropping or expiring in one browser,
  device or tab set has no effect on any other session of the same user. This
  is the bug the previous database-backed implementation had: a single
  session-less request (an API key call, an `?format=atom&key=…` feed, a
  second browser) revoked admin everywhere at an unpredictable moment.
- **Non-session access can never be elevated.** OAuth bearer tokens are
  refused explicitly (`authorized_by_oauth?`), and every other non-session
  path simply never gets the flag set.

### Become Admin / Become User

The toggle is wired directly into Redmine's built-in `Redmine::SudoMode`
password-reconfirmation feature (the same one behind `sudo_mode` /
`sudo_mode_timeout` in `configuration.yml`):

- **Become Admin** is gated by core's own `require_sudo_mode` check — if the
  user doesn't currently have a valid core sudo session (e.g. it's been more
  than `sudo_mode_timeout` minutes since they last logged in or reconfirmed
  their password), Redmine's own password form is shown; no custom UI. Note
  that logging in stamps a fresh sudo timestamp, so the first Become Admin
  shortly after login is password-free by design — that is core behaviour.
- **Become User** (manual click, or the automatic drop below) clears the
  session elevation and forces the core sudo session to be considered expired
  (`session[:sudo_timestamp] = 0`), so the next sudo-gated action — including
  a future Become Admin — requires a fresh password.
- The menu entry is only shown to users who can actually use it: sudoers who
  do not already have the `admin` column set.

### Automatic drop and the sliding window

- **Automatic drop**: a global `before_action` checks, on every request,
  whether the core sudo session has lapsed while an elevation is recorded; if
  so it clears the elevation and logs a `sudo_expired` entry in the Security
  Audit Log. The check is read-only (it doesn't itself extend the session), so
  ordinary browsing doesn't keep admin alive indefinitely — only genuinely
  admin-gated actions do that.
- **Sliding window on admin actions**: core only wires its own sliding
  behavior (a call to `Redmine::SudoMode.active?`) into the small set of
  controllers it wraps in `require_sudo_mode` (Users, Settings, Roles,
  Groups, ...). Left as-is, that means working continuously in an
  "auxiliary" admin screen that core only gates with `require_admin`
  (Trackers, Issue statuses, Enumerations, Custom fields, Workflows, ...)
  would never refresh the session and would eventually auto-drop admin mid
  task. This plugin patches `require_admin` itself to also touch
  `Redmine::SudoMode.active?` once the admin check passes, so any confirmed
  admin action slides the same window — without ever demanding a password
  for actions that didn't require one before.

If `sudo_mode: false` is set in `configuration.yml`, there is no window to
expire against: an elevation then simply lasts until Become User or logout.

### Consequences for the REST API

This is the point of the design: a sudoer's API key, OAuth token or atom key
is that of a plain user, so automation and scripts cannot bypass rules that
the UI enforces. Concretely, a sudoer calling the API:

- cannot bypass workflow transitions on `status_id`, nor workflow
  `readonly`/`required` field rules;
- sees only the issues, projects, users and saved queries their roles allow;
- does not see custom fields whose visibility is restricted by role;
- cannot use the `X-Redmine-Switch-User` header;
- cannot create, update or delete users via `/users.json`;
- cannot create public or global saved queries.

Two things worth knowing:

- **`.json` / `.xml` URLs never see the session elevation** from a logged-in
  browser, unless the controller serves the browser's session on purpose:
  Redmine core empties the session of API-formatted requests. A controller
  that keeps it gets the
  elevation like any session request, provided it drops the session again as
  soon as API credentials are supplied, since the elevation only checks that
  the session authenticated the resolved user. Redmine's own UI uses `.js`
  and format-less endpoints, so the web interface is unaffected.
- Some read-only core endpoints (`/trackers.json`, `/issue_statuses.json`,
  `/enumerations.json`, ...) are gated by core's
  `require_admin_or_api_request`, which lets *any* authenticated API user
  through regardless of admin status. That is pre-existing core behaviour and
  is out of scope for this plugin.

If you have automation that genuinely needs admin over the API, give it a
**dedicated service account** with `admin = true` and `sudoer = false`, and use
that account's API key — do not set `admin` on a human account.

### Guard against escaping the model

Only a user who already has the `admin` column set may grant that column, and
never on their own account. Without this, a sudoer who elevated could simply
tick "Administrator" on their own user and hold permanent, API-wide admin
rights. The checkbox is therefore rendered inert for everyone else, and the
attribute is stripped server-side by `safe_attribute_names`.

Two-factor authentication follows the same reasoning: core only forces 2FA on
`admin?`, which is false for a sudoer at rest, so
`Setting.twofa_required_for_administrators?` is extended to cover sudoers too.

### Notifications

Core mails "all administrators" (`User.active.where(admin: true)`) when
someone gains or loses admin and when application settings change. Since
`admin` is now expected to hold little more than a service account, both
broadcasts are widened to **admins *and* sudoers**. Personal security notices
(your mail address changed, your password changed, ...) keep their single
recipient.

## Users list "Sudoer" column

The Administration > Users list shows core's default `admin` column
(plain Yes/No) as usual, plus a `sudoer` column shown right next to it by
default, so who is permanently an administrator and who may elevate on demand
are both visible at a glance without customizing the query. Neither column
shows who is elevated *right now*, because that lives in individual sessions;
use the Security Audit Log (`sudo_activated` / `sudo_deactivated` /
`sudo_expired`) for that.

Filtering is unaffected: Redmine core's `admin` filter and this plugin's
`sudoer` filter still operate on the raw boolean columns.

## Installation

See the [Redmine plugin guide](http://www.redmine.org/projects/redmine/wiki/Plugins).
In short:

1. Drop the plugin into the `plugins/` directory.
2. Run `rake redmine:plugins:migrate`.
3. Restart your Redmine instance.

### Upgrading to the session-scoped model

Migration `005_clear_session_elevation_from_admin_column` clears `admin` on
every row that also has `sudoer` set, because under the old semantics that
combination meant "elevated at this moment" rather than "permanently an
administrator".

Before migrating, review the affected accounts:

```sql
SELECT login FROM users WHERE admin = 1 AND sudoer = 1;
```

and make sure at least one account has `admin = 1` **without** `sudoer` — a
dedicated service account is the recommended choice. If none does, the
migration still runs to completion but prints a warning, leaving the instance
with no permanent administrator until you grant one.

To grant it afterwards, from your database console:

```sql
UPDATE users SET admin = 1, sudoer = 0 WHERE login = 'service_account';
```

Also audit any stored API keys used by automation (CI jobs, backup scripts,
integrations) and move them to that service account if they rely on admin
rights.

## Compatibility

Requires Redmine >= 6.1.4 (relies on core emptying the session of API
requests, #44249). When reporting an issue, always mention the Redmine
version you are using.

## Differences from the original plugin

- Stripped away unneeded code — minimalistic approach.
- No backwards compatibility targeted; the code stays lean and mean for the
  targeted Redmine version.
- Removed the `deface` dependency, which adds complexity and is hard to manage
  alongside many plugins.

## Test status

| Plugin branch | Redmine Version | Test Status      |
|---------------|-----------------|------------------|
| redmine-6.1   | 6.1.0           | [![6.1.0][1]][2] |

[1]: https://github.com/tools-aoeur/redmine_sudo/actions/workflows/6_1_0.yml/badge.svg
[2]: https://github.com/tools-aoeur/redmine_sudo/actions

## Contribute

Contributions are welcome:

- Give feedback on what works well and what could be improved.
- Report bugs by opening an issue on GitHub.
- Fork the project and send a pull request for patches or features.
