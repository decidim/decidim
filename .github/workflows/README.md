# Decidim GitHub Actions workflows

We use GitHub Actions as CI with two key optimizations: **workflow splitting** and **composite actions**.

## Architecture

### Composite Actions

- `test_app.yml`: [Reusable workflow](https://docs.github.com/en/actions/using-workflows/reusing-workflows) that provides all common CI setup (Ruby, Node.js, database, Chrome, etc.)
- All `ci_*.yml` workflows use this composite action via `uses: ./.github/workflows/test_app.yml`
- Reduces duplication and simplifies maintenance

### Workflow Splitting

Large test suites are split into [parallel workflows](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow) to reduce execution time:

## Core Workflows

- `lint_code.yml`: Lints Ruby, JS, and ERB files
- `ci_main.yml`: Tests for main folder
- `ci_core.yml`: Base template for module testing using `test_app.yml`

## Special Cases

- `ci_generators.yml`: No test app needed, uses custom gem path setup
- `ci_javascript.yml`: Runs JS tests from project root with Node.js setup

## Split Workflows (Parallel Execution)

Modules with large test suites are split across multiple workflows:

- Proposals: `ci_proposals_system_admin.yml`, `ci_proposals_system_public.yml`, `ci_proposals_unit_tests.yml`
- Similar patterns for other large modules

## Performance Monitoring

- `ci_performance_metrics_monitoring.yml`: Lighthouse CI with budgets:
  - [First Contentful Paint](https://web.dev/first-contentful-paint/): 2s
  - [Speed Index](https://web.dev/speed-index/): 4s
  - [Time to Interactive](https://web.dev/interactive/): 5s
  - [Largest Contentful Paint](https://web.dev/lcp/): 2.5s
