# frozen_string_literal: true

module Decidim
  module Exporters
    # rubocop: disable Rails/ApplicationController
    # A dummy controller to render views while exporting questionnaires
    class FormPDFControllerHelper < ActionController::Base
      # rubocop: enable Rails/ApplicationController
      helper Decidim::TranslationsHelper
      helper Decidim::Forms::Admin::QuestionnaireAnswersHelper
    end
  end
end
