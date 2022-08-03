# frozen_string_literal: true

namespace :decidim do
  desc "Install migrations from Decidim to the app."
  task upgrade: [
    :choose_target_plugins,
    :"decidim:upgrade_app",
    :"railties:install:migrations",
    :"decidim:webpacker:upgrade",
    :"decidim_api:generate_docs"
  ]

  desc "Setup environment so that only decidim migrations are installed."
  task :choose_target_plugins do
    ENV["FROM"] = %w(
      decidim
      decidim_accountability
      decidim_admin
      decidim_assemblies
      decidim_blogs
      decidim_budgets
      decidim_comments
      decidim_conferences
      decidim_consultations
      decidim_debates
      decidim_elections
      decidim_forms
      decidim_initiatives
      decidim_meetings
      decidim_pages
      decidim_participatory_processes
      decidim_proposals
      decidim_sortitions
      decidim_surveys
      decidim_system
      decidim_templates
      decidim_verifications
    ).join(",")
  end

  desc "Applies upgrade modifications to the already installed application."
  task :upgrade_app do
    FileUtils.rm("public/favicon.ico", force: true)
  end
end
