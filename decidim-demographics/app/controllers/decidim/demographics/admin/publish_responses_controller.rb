# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      # Mind that even though the name of the controller, currently we do not allow the publication.
      # This is only for showing to the admin the visualization of the responses
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
