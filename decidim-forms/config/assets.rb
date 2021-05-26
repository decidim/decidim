# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_forms: "#{base_path}/app/packs/entrypoints/decidim_forms.js",
  decidim_forms_admin: "#{base_path}/app/packs/entrypoints/decidim_forms_admin.js",
  decidim_questionnaire_answers_pdf: "#{base_path}/app/packs/entrypoints/decidim_questionnaire_answers_pdf.js"
)
