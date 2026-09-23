# Security

This file is the **single source of truth** for security rules in Decidim development and code review. Every rule below corresponds to a vulnerability class Decidim has actually shipped (published CVEs / GitHub Security Advisories, 2023–2026). Treat violations as release blockers.

Advisory sources: <https://github.com/decidim/decidim/security/advisories>

## 1. Authorization (Broken Access Control)

CVE-2026-40869 (anyone accepts amendments), CVE-2026-40870 (comments API without permission checks), GHSA-639h-86hw-qcjq (templates admin, Critical), CVE-2026-45415 (CSV census endpoints), GHSA-vq6j-hj8w-7v39 (forms question editor), GHSA-86fh-w43w-338c (verification cross-org).

- Every **user-accessible operation** (controller action, GraphQL field/resolver/mutation, or other public entry point) must be covered by the permission system (`allowed_to?` / permissions classes). Authorization may be enforced directly at the entry point or inherited from an enclosing boundary — e.g. a GraphQL type's `self.authorized?` (as in `ComponentType`, `UserType`, `ProposalType`) covers its fields. What matters is that no user-reachable path executes without a permission check. Commands are not expected to each perform their own `allowed_to?` (internal commands may have no requesting user); the boundary that accepts user input must be checked. **Authentication is not authorization.**
- Admin endpoints must verify the admin role per action. Do not rely on controller-level filters that can be skipped, and do not assume "only admins can reach this route".
- Participant actions must verify the current user's relation to the specific resource (author, co-author, etc.). Never trust client-supplied IDs for authorization decisions.
- GraphQL is publicly reachable by default (`/api`). Any field exposing a resource must apply the same permission checks as the HTML controllers. Never add root-level fields that bypass resource-level permissions.
- Every permission change requires specs proving that unauthenticated users, wrong-role users, and users from other organizations are denied.

## 2. Multi-tenancy (organization boundaries)

CVE-2026-45414 (JWT replayed across organizations), GHSA-86fh-w43w-338c (verification IDs cross-org).

- Scope all queries for **organization-owned records** through the current organization (`current_organization` or `record.organization`). Never look up records by ID alone in controllers, commands, or resolvers. This rule does not apply to installation-wide resources that have no organization relation (e.g. `Decidim::System::Admin`, or the `Decidim::Organization` lookup that resolves the tenant root itself) — those are system-level, not tenant data, but their access must still be guarded by the appropriate role/authentication boundary.
- API credentials (JWT, API users) must be bound to the organization that issued them. A validly-signed token from another organization must be rejected.
- A role granted in one organization must never grant access to another organization's data.

## 3. SQL Injection

CVE-2026-45376 (admin user search, injection through `ORDER BY`), GHSA-jm79-9pm4-vrw9 (Ransack data exfiltration).

- Never interpolate user input into SQL fragments: `order(Arel.sql("... #{term} ..."))`, `where("... #{...}")`, `pluck` with SQL strings, etc.
- `sanitize_sql_array` is safe only when values are passed as bound placeholders: `sanitize_sql_array(["... :term ...", { term: input }])`. It does **not** protect you if user input is interpolated into the SQL template itself — `sanitize_sql_array(["... #{input} ..."])` is vulnerable, because interpolation happens before sanitization and Rails receives an already-built SQL string. This exact mistake caused CVE-2026-45376.
- For dynamic ordering, map user input to a whitelist of allowed column/direction pairs.
- Ransack: always define `ransackable_attributes` and `ransackable_associations` allow-lists. Never leave the default allow-all behavior for public controllers.
- Test search/sort inputs with SQL metacharacters (`'`, `;`, `--`) asserting no injection.

## 4. XSS / Stored Script Execution

CVE-2026-23891 (user name, Critical), GHSA-rx9f-5ggv-5rh6 (admin activity log), GHSA-7cx8-44pc-xv3q (pagination `per_page`), GHSA-5652-92r9-3fx9 (processes filter), GHSA-vvqw-fqwx-mqmm (QuillJS editor), GHSA-j4h6-gcj7-7v9v (meeting embeds), GHSA-cc4g-m3g7-xmw8 (version control page), GHSA-533c-2vh9-4r86 (HTML content blocks), GHSA-9mvp-w4rr-5c6x (election titles), GHSA-9w99-78rj-hmxq (dynamic file uploads), GHSA-529p-jj47-w3m3 (admin panel).

- Never mark user-controlled content as `html_safe` or pass it to `raw`. This includes names, nicknames, titles, addresses, and values taken from `params`.
- Escape explicitly wherever Rails does not escape for you: cells, JavaScript data attributes, JSON embedded in views, plain-text emails, log pages.
- Query-string values rendered into HTML or JS (pagination, filters, search terms) must be escaped/sanitized server-side.
- Rich text (WYSIWYG) content must be sanitized **server-side before output**, using the existing scrubbers/pipeline (`decidim_sanitize` / `decidim_sanitize_editor` / `render_sanitized_content`). Never trust the client editor's output — attackers can POST directly to the endpoint. Sanitizing on save instead of on render is a deliberate architectural change: if you introduce a save-time sanitization invariant, document and validate it (all existing render paths, exports, and API representations must honor it); do not assume the rest of the pipeline already sanitizes at render time.
- Validate/sanitize embedded content (iframes, embed URLs) and uploaded files (including SVG) server-side.
- Any new surface that renders user data (activity logs, content blocks, version pages, export titles) must be reviewed for escaping.

## 5. Data Exposure (signed URLs, exports, private files)

CVE-2026-45378 (identity documents via 7-day signed Active Storage disk URLs), GHSA-767h-63j4-5226 (private exports via reusable links), CVE-2025-65017 (export UUID collisions).

- A signed Active Storage URL (`url`, `variant_url`, `representation`) is a **bearer credential** valid until expiry. Never use it for private or sensitive uploads — route files through a controller that checks authorization on every request.
- Generated exports must not be downloadable from guessable or unguarded URLs; enforce permission checks at download time.
- Avoid low-entropy or reused identifiers for security-relevant generated resources (file names, tokens, links).
- Do not log or embed sensitive data (tokens, PII, verification documents) in URLs, logs, or analytics.

## 6. CSRF, SSRF, Redirects, Tokens, Race Conditions

- Never disable or override `protect_from_forgery`, and never skip authenticity token verification for any action (GHSA-f3qm-vfc3-jg6v).
- Any feature making the server fetch a URL (webhooks, push subscriptions, imports) must block private/internal addresses and validate redirects. Features with fixed, known destinations (e.g. a webhook you configure once) must additionally restrict targets to an allow-list (GHSA-2g9c-vf8h-prxx). Features that intentionally accept arbitrary public URLs from users (e.g. participatory-process imports) do not need an allow-list, but they must still apply address/redirect validation, scheme restrictions, timeouts, and size limits so the fetch cannot reach internal services.
- Validate external redirect targets (scheme and host); never `redirect_to params[...]` unchecked (GHSA-469h-mqg8-535r).
- Tokens (invitations, password resets, uploads) must enforce expiry server-side on every use (GHSA-w3q8-m492-4pwp).
- Counters and quotas (endorsements, votes, budget allocations) need database-atomic updates or cross-process-safe locking to survive concurrent requests (GHSA-r275-j57c-7mf2). Process-local thread locks are insufficient.

## Required Tests

| Change | Required test |
|---|---|
| New user-accessible endpoint / mutation / resolver | Permission spec: wrong-role, unauthenticated, and cross-org attempts are denied (not required for internal commands with no user boundary; resource-level authorization inherited from the enclosing type still needs denial coverage) |
| New rendering of user data | Escaping/sanitization spec with a malicious payload (e.g. `<script>`) |
| New SQL search/sort | Spec with SQL metacharacters in input asserting no injection |
| New file serving / export | Spec asserting unauthenticated and unauthorized users cannot fetch the file |
| New counter/vote logic | Concurrency or atomicity spec |
| Changes to organization-scoped queries or API-credential binding | Spec proving same-organization access succeeds and other-organization access is denied |

## Review Guidance

Reviewers must apply this file as a blocking checklist on every diff. Any violation of the rules above is a **Critical issue** (must fix before merge). A new endpoint without a permission spec is itself a blocker.
