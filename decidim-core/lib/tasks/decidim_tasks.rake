# frozen_string_literal: true

namespace :decidim do
  desc "Performs upgrade tasks (migrations, node, docs )."
  task upgrade: [
    :choose_target_plugins,
    :"decidim:upgrade_app",
    :"railties:install:migrations",
    :"decidim:upgrade:migrations",
    :"decidim:upgrade:webpacker",
    :"decidim_api:generate_docs"
  ]

  task update: [:upgrade]

  desc "Sets up environment so that only decidim migrations are installed."
  task :choose_target_plugins do
    ENV["FROM"] = %w(
      decidim
      decidim_accountability
      decidim_admin
      decidim_assemblies
      decidim_blogs
      decidim_budgets
      decidim_collaborative_texts
      decidim_comments
      decidim_conferences
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
  task upgrade_app: [:"decidim:remove_default_favicon"]

  desc "Removes the default favicon from the application."
  task :remove_default_favicon do
    FileUtils.rm("public/favicon.ico", force: true)
  end
end
