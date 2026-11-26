# Security

This file is the **single source of truth** for security rules in Decidim development and code review. Sections 1–6 correspond to vulnerability classes Decidim has actually shipped (published CVEs / GitHub Security Advisories, 2023–2026). Section 7 covers additional classes and is non-exhaustive; it is not tied to a specific advisory. Treat violations as release blockers.

Advisory sources: <https://github.com/decidim/decidim/security/advisories>

## 1. Authorization (Broken Access Control)

CVE-2026-40869 (anyone accepts amendments), CVE-2026-40870 (comments API without permission checks), GHSA-639h-86hw-qcjq (templates admin, Critical), CVE-2026-45415 (CSV census endpoints), GHSA-vq6j-hj8w-7v39 (forms question editor), GHSA-86fh-w43w-338c (verification cross-org).

- Every **user-accessible operation** (controller action, GraphQL field/resolver/mutation, or other public entry point) must be covered by the permission system (`allowed_to?` / permissions classes). Authorization may be enforced directly at the entry point or inherited from an enclosing boundary — e.g. a GraphQL type's `self.authorized?` (as in `ComponentType`, `UserType`, `ProposalType`) covers its fields. What matters is that no user-reachable path executes without a permission check. Commands are not expected to each perform their own `allowed_to?` (internal commands may have no requesting user); the boundary that accepts user input must be checked. **Authentication is not authorization.**
- Admin endpoints must verify the admin role per action. Do not rely on controller-level filters that can be skipped, and do not assume "only admins can reach this route".
- Participant actions must verify the current user's relation to the specific resource (author, co-author, etc.). Never trust client-supplied IDs for authorization decisions.
- GraphQL is publicly reachable by default (`/api`). Any field exposing a resource must apply the same permission checks as the HTML controllers. Never add root-level fields that bypass resource-level permissions.
- Every permission change requires specs testing the intended access policy: assert denials for unauthenticated users, roles, or organizations that the policy denies, and confirm that access succeeds when the policy allows it.

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

## 7. Additional Security Classes
(Non-Exhaustive)

Sections 1–6 cover CVE-derived classes. These additional classes are reviewed with the same severity and are not tied to a specific advisory.

**Authentication**

- Do not reveal whether an account exists through sign-in, registration, password-reset, or invitation responses, status codes, or timing (`config.paranoid = true`, Devise `send_paranoid_instructions`).
- Changing an email requires the current password and confirmation of the new address; never authenticate or authorize on an unconfirmed email (`AccountForm#validate_old_password`, `unconfirmed_email`).
- Password-reset and invitation tokens must be single-use and invalidated on acceptance or password change; expiry rules are in §6 (`Devise.reset_password_within`).
- Rotate the session identifier on sign-in; call `invalidate_all_sessions!` on sign-out, password/email change, role change, and impersonation end, and never carry pre-authentication session state across the boundary.
- Link OAuth identities to existing accounts only when the provider asserts a verified email; never link on an unverified, user-typed, or stale session address (`CreateOmniauthRegistration`, `verified_email`).
- Impersonation requires an active persisted log (admin, user, reason, start/end) and a hard server-side expiry; the session must end when the log ends (`ImpersonationLog::SESSION_TIME_IN_MINUTES`, `ExpireImpersonationJob`, `ImpersonateUsers`).
- Managed users must not be able to sign in directly; they are reachable only through authorized impersonation. Blocked or deleted users are signed out and denied on every request, not only at sign-in (`UserBlockedChecker`, `deleted_at`).

**Authorization**

- Look records up through the current organization, component, and participatory space, and through visible/published scopes (`not_hidden`, `published`); a guessed ID must not reveal hidden, unpublished, or cross-tenant records to callers without preview or staff access (see §2 and the share-token bullet below).
- Strong parameters must be explicit: never `permit!`, and never permit `role`, `organization`, owner/author, `state`, or admin flags from participant input; derive them server-side.
- Role, officialization, and organization membership changes are admin-only; participants cannot elevate themselves or another user through profile, invitation, or API forms.
- Share tokens grant only the preview access they encode: validate the token against the resource and organization, honor `expires_at` and `registered_only`, and never treat a token as staff authorization (`Decidim::ShareToken`; expiry in §6).
- `ActionAuthorizer` checks must apply to every entry point, not just HTML controllers. Commands, jobs, and GraphQL mutations that perform a gated action (e.g. initiative signatures, comments) must revalidate or be callable only behind an authorized boundary (see §1).
- Moderation actions must be scoped to the moderations the admin can manage (`GlobalModerationContext#moderations_for_user`, `Decidim::Admin::ModerationStats`); participants may report only visible content, and hidden/deleted content must not become reachable through moderation views.

**Voting integrity**

- One vote/order per participant must be enforced by a database unique constraint, not a model validation alone. For multi-option ballots, constrain each option and lock the question so the ballot cannot be duplicated (`decidim_budgets_order_user_feature_unique`, `decidim_elections_votes` index, and `CastVotes` locking each question with `with_lock`).
- Duplicate and concurrent submissions must fail safely: rescue `ActiveRecord::RecordNotUnique`, keep the operation idempotent, and never double-count a retry.
- Census validation and vote persistence must use the same voter identity and run atomically: `UsesCensusAccess` must not authorize one identity while `CastVotes` records another, and the election state must be rechecked inside the transaction.
- Enforce start/end deadlines and question voting windows server-side (`ongoing?`, `voting_enabled_at`); never rely on the client clock, hidden fields, or disabled UI.
- Ballot secrecy: never expose an individual voter's choices through logs, exports, GraphQL, admin responses, or notifications; publish aggregates only.
- Pre-close results: no counts, percentages, or per-option breakdowns before `results_at`/`published_results_at`; gate every result surface, including JSON and API.
- Budget orders must enforce minimum/maximum projects, budget caps, and checkout deadlines server-side; reject totals, hidden fields, or line items that bypass the rules (`Decidim::Budgets::Order`).
- Keep counters consistent with the authoritative rows and recompute under concurrency (`update_votes_count!`, counter caches); see §6. Exports of votes, orders, and census data require the same authorization and scoping as the UI (see §5).

**Other classes**

- Never `constantize`, `safe_constantize`, `send`, or `public_send` on user-controlled names; resolve through manifests or allow-lists. Parse YAML with `safe_load` and permitted classes; `unsafe_load` only for trusted internal data.
- File paths built from params must be canonicalized and confined to an allow-listed root; reject `..`, absolute paths, and null bytes (`send_file`, `File.join`, render paths).
- Validate uploads server-side: content type by magic bytes, extension allow-list, size, and dimensions; sanitize SVG and reject polyglots or executables (`HasUploadValidations`, uploaders; see §4).
- Keep GraphQL `max_depth`, `max_complexity`, and `default_max_page_size` enabled and bounded; no unbounded nested or recursive queries (`Decidim::Api.schema_max_depth`, `schema_max_complexity`, `schema_max_per_page`).
- Background jobs and webhook handlers must re-fetch and revalidate their records, verify signatures, limit payload size, and be idempotent; never trust serialized arguments as authorization (SSRF controls in §6).
- Keep `Rack::Attack` throttles for sign-in, password reset, verification, and API traffic; do not add blanket exemptions, and key limits on both IP and account where relevant (`decidim-core/config/initializers/rack_attack.rb`).
- Do not commit, log, or place secrets in URLs; use credentials/environment configuration. Cookies must be `secure`, `httponly`, and `same_site` as appropriate, and CSP must not gain `unsafe-inline`/`unsafe-eval` or widened sources without review (`Decidim::ContentSecurityPolicy`, session-store `secure` option).

## Required Tests

| Change                                                           | Required test                                                                                                                                                                                                                          |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| New user-accessible endpoint / mutation / resolver               | Permission spec testing the intended access policy: denial attempts the policy refuses are rejected, and allowed access succeeds (not required for internal commands; inherited type-level authorization still needs denial coverage)  |
| New rendering of user data                                       | Escaping/sanitization spec with a malicious payload (e.g. `<script>`)                                                                                                                                                                  |
| New SQL search/sort                                              | Spec with SQL metacharacters in input asserting no injection                                                                                                                                                                           |
| New file serving / export                                        | Spec asserting unauthenticated and unauthorized users cannot fetch the file                                                                                                                                                            |
| New counter/vote logic                                           | Concurrency or atomicity spec                                                                                                                                                                                                          |
| New CSRF-protected action or form                                | Spec asserting the action rejects requests without a valid authenticity token                                                                                                                                                          |
| New token generation or verification                             | Spec asserting expired tokens are rejected when the token has an expiry policy. Tokens without expiry (e.g. share tokens with `expires_at: nil`) have no expired state: spec instead that they stay valid                              |
| New server-side URL fetch                                        | Spec covering private/internal addresses, redirect hops, schemes, timeouts, and response-size limits                                                                                                                                   |
| New external redirect                                            | Spec covering allowed schemes and hosts                                                                                                                                                                                                |
| Changes to organization-scoped queries or API-credential binding | Spec proving same-organization access succeeds and other-organization access is denied                                                                                                                                                 |
| New authentication flow                                          | Spec covering enumeration-safe responses, email-change re-auth, token expiry/single use, session rotation, verified-email OAuth linking, impersonation logging/expiry, and denial for managed, blocked, and deleted users              |
| New/changed lookup by client-supplied ID                         | Spec proving hidden/unpublished records and records from another organization, component, or participatory space are denied to callers without preview or staff access (IDOR; see §2 and the share-token row)                          |
| New or changed strong parameters/form                            | Spec proving `role`, `organization`, owner/author, `state`, and admin flags cannot be mass-assigned, and privilege escalation is rejected                                                                                              |
| New or changed share-token/preview path                          | Spec proving wrong-resource and wrong-organization tokens are rejected, `expires_at`/`registered_only` are enforced, and preview access cannot perform staff actions                                                                   |
| New command, job, or API path for an authorized action           | Spec proving the same `ActionAuthorizer`/permission policy applies outside the HTML controller, with denial coverage                                                                                                                   |
| New or changed vote/order/endorsement/like path                  | Spec asserting the database unique constraint rejects duplicate and concurrent records, retries are idempotent, and counters stay consistent                                                                                           |
| New election, census, or results surface                         | Spec covering deadlines, census/vote atomicity across `UsesCensusAccess` and `CastVotes`, ballot secrecy, and denial of pre-publication results                                                                                        |
| New budget order/checkout logic                                  | Spec covering minimum/maximum projects, budget caps, and post-deadline rejection                                                                                                                                                       |
| New dynamic constant, method, YAML, or file path                 | Spec with attacker-controlled names/paths asserting allow-list rejection, `safe_load`, and no path traversal                                                                                                                           |
| New upload surface                                               | Spec with spoofed content type/extension, oversized files, and malicious SVG asserting rejection/sanitization                                                                                                                          |
| New GraphQL field or connection                                  | Spec covering authorization plus depth, complexity, and page-size limits                                                                                                                                                               |
| New background job or webhook handler                            | Spec covering record revalidation, signature verification, payload limits, idempotency, and unauthorized invocation                                                                                                                    |
| New rate-limited endpoint or Rack::Attack rule                   | Spec proving thresholds apply and no blanket exemption or bypass is introduced                                                                                                                                                         |
| New cookie, CSP, or secret handling                              | Spec/config assertion for `secure`/`httponly`/`same_site` cookies and CSP without unsafe additions                                                                                                                                     |

## Review Guidance

Reviewers must apply this file as a blocking checklist on every diff. Any violation of the rules above is a **Critical issue** (must fix before merge). A new endpoint without a permission spec is itself a blocker. Section 7 is non-exhaustive: if a diff exposes a credible weakness that no listed rule names, raise it as a blocker rather than assuming it is safe. Absence of a matching rule is not evidence of safety; block on any credible weakness.
