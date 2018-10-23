# frozen_string_literal: true

module Decidim
  module Proposals
    # A factory class to ensure we always create Proposals the same way since it involves some logic.
    module ProposalBuilder
      # Public: Creates a new Proposal.
      def create(attributes:, author:, action_user:, user_group_author: nil)
        Decidim.traceability.perform_action!(:create, Proposal, action_user, visibility: "all") do
          proposal = Proposal.new(attributes)
          proposal.add_coauthor(author, user_group: user_group_author)
          proposal.save!
          proposal
        end
      end

      module_function :create

      # Public: Creates a new Proposal by copying the attributes from another one.
      # rubocop:disable Metrics/ParameterLists
      def copy(original_proposal, author:, action_user:, user_group_author: nil, extra_attributes: {}, skip_link: false)
        origin_attributes = original_proposal.attributes.except(
          "id",
          "created_at",
          "updated_at",
          "state",
          "answer",
          "answered_at",
          "decidim_component_id",
          "reference",
          "proposal_votes_count",
          "proposal_notes_count"
        ).merge(
          "category" => original_proposal.category
        ).merge(
          extra_attributes
        )

        proposal = create(
          attributes: origin_attributes,
          author: author,
          user_group_author: user_group_author,
          action_user: action_user
        )

        proposal.link_resources(original_proposal, "copied_from_component") unless skip_link
        proposal
      end
      # rubocop:enable Metrics/ParameterLists

      module_function :copy
    end
  end
end
