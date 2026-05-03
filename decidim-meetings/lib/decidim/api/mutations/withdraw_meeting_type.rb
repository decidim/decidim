# frozen_string_literal: true

module Decidim
  module Meetings
    class WithdrawMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "WithdrawMeeting"

      description "Withdraws a meeting"
      type Decidim::Meetings::MeetingType

      def resolve
        WithdrawMeeting.call(object, current_user) do
          on(:ok) do |meeting|
            return meeting
          end

          on(:invalid) do
            raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.meetings.withdraw.error")
          end
        end
      end

      def authorized?
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:withdraw, :meeting, object, context)

        true
      end
    end
  end
end
