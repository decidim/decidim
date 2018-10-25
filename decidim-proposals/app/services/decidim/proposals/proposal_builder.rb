# frozen_string_literal: true

module Decidim
  module Proposals
    # A factory class to ensure we always create Proposals the same way since it involves some logic.
    module ProposalBuilder
      # Public: Creates a new Proposal.
      #
      # attributes        - The Hash of attributes to create the Proposal with.
      # author            - An Authorable the will be the first coauthor of the Proposal.
      # user_group_author - A User Group to, optionally, set it as the author too.
      # action_user       - The User to be used as the user who is creating the proposal in the traceability logs.
      #
      # Returns a Proposal.
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
      #
      # original_proposal - The Proposal to be used as base to create the new one.
      # author            - An Authorable the will be the first coauthor of the Proposal.
      # user_group_author - A User Group to, optionally, set it as the author too.
      # action_user       - The User to be used as the user who is creating the proposal in the traceability logs.
      # extra_attributes  - A Hash of attributes to create the new proposal, will overwrite the original ones.
      # skip_link         - Whether to skip linking the two proposals or not (default false).
      #
      # Returns a Proposal
      #
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
