# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class PublishResponsesController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper

        helper PublishResponsesHelper
        helper_method :questionnaire_for, :questionnaire

        def index
          enforce_permission_to(:index, :demographics)
        end

        def questionnaire_url
          responses_path
        end
      end
    end
  end
end
