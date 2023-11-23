# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalType < Decidim::Api::Types::BaseObject
      description "A proposal"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CoauthorableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::FingerprintInterface
      implements Decidim::Core::AmendableInterface
      implements Decidim::Core::AmendableEntityInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::EndorsableInterface
      implements Decidim::Core::TimestampsInterface

      field :id, GraphQL::Types::ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this title", null: true
      field :body, Decidim::Core::TranslatedFieldType, "The description for this body", null: true
      field :address, GraphQL::Types::String, "The physical address (location) of this proposal", null: true
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this proposal", null: true

      def coordinates
        [object.latitude, object.longitude]
      end
      field :reference, GraphQL::Types::String, "This proposal's unique reference", null: true
      field :state, GraphQL::Types::String, "The answer status in which proposal is in", null: true
      field :answer, Decidim::Core::TranslatedFieldType, "The answer feedback for the status for this proposal", null: true

      field :answered_at, Decidim::Core::DateTimeType, description: "The date and time this proposal was answered", null: true

      field :published_at, Decidim::Core::DateTimeType, description: "The date and time this proposal was published", null: true

      field :participatory_text_level, GraphQL::Types::String, description: "If it is a participatory text, the level indicates the type of paragraph", null: true
      field :position, GraphQL::Types::Int, "Position of this proposal in the participatory text", null: true

      field :official, GraphQL::Types::Boolean, "Whether this proposal is official or not", method: :official?, null: true
      field :created_in_meeting, GraphQL::Types::Boolean, "Whether this proposal comes from a meeting or not", method: :official_meeting?, null: true
      field :meeting, Decidim::Meetings::MeetingType, description: "If the proposal comes from a meeting, the related meeting", null: true

      def meeting
        object.authors.first if object.official_meeting?
      end

      field :vote_count, GraphQL::Types::Int, description: "The total amount of votes the proposal has received", null: true

      def vote_count
        current_component = object.component
        object.proposal_votes_count unless current_component.current_settings.votes_hidden?
      end
    end
  end
end
