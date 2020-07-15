# frozen_string_literal: true

module Decidim
  module Exporters
    # A dummy controller to render views while exporting questionnaires
    class FormPDFControllerHelper < ActionController::Base
      helper Decidim::TranslationsHelper
      helper Decidim::Forms::Admin::QuestionnaireAnswersHelper
    end
  end
end
