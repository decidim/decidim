# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      module Concerns
        # Use this concern if your resource model class includes the
        # `HasMultipleQuestionnaires` concern.
        #
        # Questionnaires can be related to any class in Decidim, in order to
        # manage the questionnaires for a given type, you should create a new
        # controller and include this concern.
        #
        # The only requirement is to define a `questionnaire_for` method that
        # returns an instance of the model that questionnaire belongs to.
        module HasMultipleQuestionnaires
          extend ActiveSupport::Concern

          included do
            include Decidim::Forms::Admin::Concerns::HasQuestionnaire

            helper_method :questionnaires

            def index
              if questionnaire_for.questionnaires.count == 1
                redirect_to action: :edit, id: questionnaire_for.questionnaires.first.id
              else
                render template: "decidim/forms/admin/questionnaires/index"
              end
            end

            # You can implement this method in your controller to change the URL
            # where the questionnaire will be submitted.
            def update_url
              url_for(questionnaire)
            end

            # You can implement this method in your controller to change the URL
            # where the user will be redirected after updating the questionnaire
            def after_update_url
              url_for(action: :index)
            end

            private

            def questionnaire
              @questionnaire ||= questionnaires.find_by(id: params[:id])
            end

            def questionnaires
              @questionnaires ||=
                Questionnaire
                .where(questionnaire_for: questionnaire_for)
            end
          end
        end
      end
    end
  end
end
