# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Custom helpers, scoped to the templates engine.
      #
      module TemplatesHelper
        def select_template(form, templates)
          prompt_options = {
            url: decidim_admin_templates.questionnaire_templates_url(format: :json),
            change_url: decidim_admin_templates.preview_questionnaire_templates_url(format: :js),
            placeholder: t("placeholder", scope: "decidim.templates.admin.questionnaire_templates.choose")
          }

          default_options = templates.last(5).map { |questionnaire_template| { value: questionnaire_template.id, label: translated_attribute(questionnaire_template.name) } }

          form.autocomplete_select(
            :questionnaire_template_id,
            false,
            {
              multiple: false,
              label: t("label", scope: "decidim.templates.admin.questionnaire_templates.choose"),
              default_options: default_options
            },
            prompt_options
          )
        end
      end
    end
  end
end
