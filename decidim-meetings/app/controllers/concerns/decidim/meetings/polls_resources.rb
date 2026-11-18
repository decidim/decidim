# frozen_string_literal: true

module Decidim
  module Meetings
    # This module, when injected into a controller, loads all the resources
    # to display and interact with meeting polls.
    module PollsResources
      extend ActiveSupport::Concern

      included do
        helper_method :meeting, :poll, :questionnaire
      end

      private

      def meeting
        @meeting ||= Meeting.not_hidden.where(component: current_component).find(params.expect(:meeting_id))
      end

      def poll
        @poll ||= meeting&.poll
      end

      def questionnaire
        # rubocop:disable-next Decidim/OrganizationScopedFinder -- poll belongs to the meeting, which is scoped to current_component
        @questionnaire ||= Decidim::Meetings::Questionnaire.find_by(questionnaire_for: poll) if poll
      end
    end
  end
end
