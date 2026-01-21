# Important Notes

- **NEVER CANCEL** builds or tests that take more than 2 minutes - builds can take 3+ minutes, full test suites for a module 60+ minutes
- Always use the exact Ruby and Node versions specified in `.ruby-version` and `.node-version`.
- The development app (`rake development_app`) is the primary way to create a working Decidim application for development
- Each `decidim-*` directory is an independent gem with its own tests and dependencies
- Always run full validation scenarios after making changes to ensure functionality works end-to-end
- **Changes to decidim-generators**: When making changes to `decidim-generators` that affect application configuration (files like `config/application.rb`, `config/environments/*`, etc) or other generated files, also document these changes in `RELEASE_NOTES.md`
- Read more about testing (like how to run parallel tests) at @docs/modules/develop/pages/testing.adoc
