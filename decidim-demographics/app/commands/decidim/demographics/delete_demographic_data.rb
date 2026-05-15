# frozen_string_literal: true

module Decidim
  module Demographics
    class DeleteDemographicData < Decidim::Command
      # Initializes a DeleteDemographicData Command.
      #
      # @param questionnaire [Decidim::Forms::Questionnaire] The questionnaire containing demographic data
      # @param user [Decidim::User] The user whose demographic data should be deleted
      def initialize(questionnaire, user)
        @questionnaire = questionnaire
        @user = user
      end

      def call
        @questionnaire.responses.where(user: @user).destroy_all

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end
    end
  end
end
