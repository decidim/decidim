# frozen_string_literal: true

module Decidim
  module Meetings
    class WithdrawMeetingType < Decidim::Api::Types::BaseMutation
      graphql_name "WithdrawMeeting"

      description "Withdraws a meeting"
      type Decidim::Meetings::MeetingType

      argument :attributes, WithdrawMeetingAttributes, description: "input attributes for withdrawing a meeting", required: false

      def resolve(attributes: {})
        WithdrawMeeting.call(object, current_user) do
          on(:ok) do |meeting|
            return meeting
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              I18n.t("decidim.meetings.withdraw.error")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.meetings.withdraw.error")
          )
        end
      end

      def authorized?(attributes: {})
        super && allowed_to?(:withdraw, :meeting, object, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
