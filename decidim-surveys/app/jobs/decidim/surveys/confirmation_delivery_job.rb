# frozen_string_literal: true

module Decidim
  module Surveys
    class ConfirmationDeliveryJob < ApplicationJob
      queue_as :default

      def perform(user, questionnaire, component, answers)
        SurveyConfirmationMailer.confirmation(user, questionnaire, component, answers).deliver_now
      end
    end
  end
end
