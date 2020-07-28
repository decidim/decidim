# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalType = GraphQL::ObjectType.define do
      name "Proposal"
      description "A proposal"

      interfaces [
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::CoauthorableInterface },
        -> { Decidim::Core::CategorizableInterface },
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Core::FingerprintInterface },
        -> { Decidim::Core::AmendableInterface },
        -> { Decidim::Core::AmendableEntityInterface },
        -> { Decidim::Core::TraceableInterface },
        -> { Decidim::Core::EndorsableInterface },
        -> { Decidim::Core::TimestampsInterface }
      ]

      field :id, !types.ID
      field :title, !types.String, "This proposal's title" do
        resolve lambda { |obj, _args, _ctx|
          obj.title.values.first
        }
      end
      field :body, types.String, "This proposal's body" do
        resolve lambda { |obj, _args, _ctx|
          obj.body.values.first
        }
      end
      field :address, types.String, "The physical address (location) of this proposal"
      field :coordinates, Decidim::Core::CoordinatesType, "Physical coordinates for this proposal" do
        resolve ->(proposal, _args, _ctx) {
          [proposal.latitude, proposal.longitude]
        }
      end
      field :reference, types.String, "This proposal's unique reference"
      field :state, types.String, "The answer status in which proposal is in"
      field :answer, Decidim::Core::TranslatedFieldType, "The answer feedback for the status for this proposal"

      field :answeredAt, Decidim::Core::DateTimeType do
        description "The date and time this proposal was answered"
        property :answered_at
      end

      field :publishedAt, Decidim::Core::DateTimeType do
        description "The date and time this proposal was published"
        property :published_at
      end

      field :participatoryTextLevel, types.String do
        description "If it is a participatory text, the level indicates the type of paragraph"
        property :participatory_text_level
      end
      field :position, types.Int, "Position of this proposal in the participatory text"

      field :official, types.Boolean, "Whether this proposal is official or not", property: :official?
      field :createdInMeeting, types.Boolean, "Whether this proposal comes from a meeting or not", property: :official_meeting?
      field :meeting, Decidim::Meetings::MeetingType do
        description "If the proposal comes from a meeting, the related meeting"
        resolve ->(proposal, _, _) {
          proposal.authors.first if proposal.official_meeting?
        }
      end

      field :voteCount, types.Int do
        description "The total amount of votes the proposal has received"
        resolve ->(proposal, _args, _ctx) {
          current_component = proposal.component
          proposal.proposal_votes_count unless current_component.current_settings.votes_hidden?
        }
      end
    end
  end
end
