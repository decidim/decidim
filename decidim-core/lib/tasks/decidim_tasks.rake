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
  task upgrade_app: [:"decidim:remove_default_favicon", :"decidim:upgrade_ruby_version"]

  desc "Removes the default favicon from the application."
  task :remove_default_favicon do
    FileUtils.rm("public/favicon.ico", force: true)
  end

  task :upgrade_ruby_version do
    template_dir = "#{Gem.loaded_specs["decidim-generators"].full_gem_path}/lib/decidim/generators/app_templates"
    FileUtils.cp("#{template_dir}/.ruby-version", ".")
  end
end
