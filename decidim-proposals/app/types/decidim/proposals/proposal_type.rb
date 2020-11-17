# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalType < GraphQL::Schema::Object
      graphql_name "Proposal"
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

      field :id, ID, null: false, description: "The internal ID of this proposal"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description:  "The title for this title"
      field :body, Decidim::Core::TranslatedFieldType,null: true, description:  "The description for this body"
      field :address, String, null: true, description:  "The physical address (location) of this proposal"
      field :coordinates, Decidim::Core::CoordinatesType, null: true, description: "Physical coordinates for this proposal" do
        def resolve(proposal, _args, _ctx)
          [proposal.latitude, proposal.longitude]
        end
      end
      field :reference, String, null: true, description:  "This proposal's unique reference"
      field :state, String, null: true, description:  "The answer status in which proposal is in"
      field :answer, Decidim::Core::TranslatedFieldType, null: true, description:  "The answer feedback for the status for this proposal"

      field :answeredAt, Decidim::Core::DateTimeType, null: true, description: "The date and time this proposal was answered" do
        def resolve(proposal, _, _)
          proposal.answered_at
        end
      end

      field :publishedAt, Decidim::Core::DateTimeType , null: true, description: "The date and time this proposal was published" do
        def resolve(proposal, _, _)
          proposal.published_at
        end
      end

      field :participatoryTextLevel, String, null: true, description: "If it is a participatory text, the level indicates the type of paragraph" do
        def resolve(proposal, _, _)
          proposal.participatory_text_level
        end
      end

      field :position, Int, null: true, description: "Position of this proposal in the participatory text"

      field :official, Boolean,null: true, description:  "Whether this proposal is official or not" do
        def resolve(proposal, _, _)
          proposal.official?
        end
      end
      field :createdInMeeting, Boolean, null: true, description: "Whether this proposal comes from a meeting or not" do
        def resolve(proposal, _, _)
          proposal.official_meeting?
        end
      end
      field :meeting, Decidim::Meetings::MeetingType ,null: true, description:  "If the proposal comes from a meeting, the related meeting" do
        def resolve(proposal, _, _)
          proposal.authors.first if proposal.official_meeting?
        end
      end

      field :voteCount, Int, null: true, description: "The total amount of votes the proposal has received"do
        def resolve(proposal, _args, _ctx)
          current_component = proposal.component
          proposal.proposal_votes_count unless current_component.current_settings.votes_hidden?
        end
      end
    end
  end
end
