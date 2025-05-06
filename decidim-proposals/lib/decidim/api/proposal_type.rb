# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalType < Decidim::Api::Types::BaseObject
      include ActiveSupport::NumberHelper

      description "A proposal"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CoauthorableInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::FingerprintInterface
      implements Decidim::Core::AmendableInterface
      implements Decidim::Core::AmendableEntityInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::EndorsableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::ReferableInterface
      implements Decidim::Core::LocalizableInterface
      implements Decidim::Core::FollowableInterface

      field :answer, Decidim::Core::TranslatedFieldType, "The answer feedback for the status for this proposal", null: true
      field :answered_at, Decidim::Core::DateTimeType, description: "The date and time this proposal was answered", null: true
      field :body, Decidim::Core::TranslatedFieldType, "The description for this body", null: true
      field :cost, GraphQL::Types::String, "The proposal cost", null: true
      field :cost_report, Decidim::Core::TranslatedFieldType, "The cost report for this proposal", null: true
      field :created_in_meeting, GraphQL::Types::Boolean, "Whether this proposal comes from a meeting or not", method: :official_meeting?, null: true
      field :execution_period, Decidim::Core::TranslatedFieldType, "The execution period for this proposal", null: true
      field :id, GraphQL::Types::ID, "The id of the Proposal", null: false
      field :meeting, Decidim::Meetings::MeetingType, description: "If the proposal comes from a meeting, the related meeting", null: true
      field :official, GraphQL::Types::Boolean, "Whether this proposal is official or not", method: :official?, null: true
      field :participatory_text_level, GraphQL::Types::String, description: "If it is a participatory text, the level indicates the type of paragraph", null: true
      field :position, GraphQL::Types::Int, "Position of this proposal in the participatory text", null: true
      field :proposal_state, Decidim::Proposals::ProposalStateType, "The proposal state for this proposal", null: true
      field :published_at, Decidim::Core::DateTimeType, description: "The date and time this proposal was published", null: true
      field :state, GraphQL::Types::String, "The answer status in which proposal is in", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this proposal", null: true
      field :vote_count, GraphQL::Types::Int, description: "The total amount of votes the proposal has received", null: true
      field :withdrawn, GraphQL::Types::Boolean, "Whether this proposal has been withdrawn or not", method: :withdrawn?, null: true
      field :withdrawn_at, Decidim::Core::DateTimeType, description: "The date and time this proposal was withdrawn", null: true

      def answered_at
        return unless object.published_state?

        object.answered_at
      end

      def answer
        return unless object.published_state?

        object.answer
      end

      def meeting
        object.authors.first if object.official_meeting?
      end

      def cost_report
        return unless proposal_has_costs? && current_settings.answers_with_costs?

        object.cost_report
      end

      def execution_period
        return unless proposal_has_costs? && current_settings.answers_with_costs?

        object.execution_period
      end

      def cost
        return unless proposal_has_costs? && current_settings.answers_with_costs?

        number_to_currency(object.cost, unit: Decidim.currency_unit)
      end

      def vote_count
        object.proposal_votes_count unless current_settings.votes_hidden?
      end

      def self.authorized?(object, context)
        context[:proposal] = object

        chain = [
          allowed_to?(:read, :proposal, object, context),
          object.published?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end

      private

      def current_settings
        object.component.current_settings
      end

      def proposal_has_costs?
        object.cost.present?
      end
    end
  end
end
