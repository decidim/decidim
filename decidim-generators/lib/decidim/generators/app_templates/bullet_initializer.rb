# frozen_string_literal: true

if defined?(Bullet)
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.stacktrace_includes = %w(
      decidim-accountability
      decidim-admin
      decidim-api
      decidim-assemblies
      decidim-blogs
      decidim-budgets
      decidim-comments
      decidim-conferences
      decidim-consultations
      decidim-core
      decidim-debates
      decidim-dev
      decidim-elections
      decidim-forms
      decidim-generators
      decidim-initiatives
      decidim-meetings
      decidim-pages
      decidim-participatory_processes
      decidim-proposals
      decidim-sortitions
      decidim-surveys
      decidim-system
      decidim-verifications
    )
  end
end
