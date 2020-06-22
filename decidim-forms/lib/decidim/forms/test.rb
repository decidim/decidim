# frozen_string_literal: true

require "decidim/forms/test/shared_examples/has_questionnaire"
require "decidim/forms/test/shared_examples/manage_questionnaires"

if (defined? Decidim::Templates)
  require "decidim/templates/test/shared_examples/uses_questionnaire_templates"
end
