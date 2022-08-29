# frozen_string_literal: true

require "open-uri"

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

      # Public: Creates a new Proposal with the authors of the `original_proposal`.
      #
      # attributes - The Hash of attributes to create the Proposal with.
      # action_user - The User to be used as the user who is creating the proposal in the traceability logs.
      # original_proposal - The proposal from which authors will be copied.
      #
      # Returns a Proposal.
      def create_with_authors(attributes:, action_user:, original_proposal:)
        Decidim.traceability.perform_action!(:create, Proposal, action_user, visibility: "all") do
          proposal = Proposal.new(attributes)
          original_proposal.coauthorships.each do |coauthorship|
            proposal.add_coauthor(coauthorship.author, user_group: coauthorship.user_group)
          end
          proposal.save!
          proposal
        end
      end

      module_function :create_with_authors

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
          "state_published_at",
          "answer",
          "answered_at",
          "decidim_component_id",
          "reference",
          "comments_count",
          "endorsements_count",
          "follows_count",
          "proposal_notes_count",
          "proposal_votes_count"
        ).merge(
          "category" => original_proposal.category
        ).merge(
          extra_attributes
        )

        proposal = if author.nil?
                     create_with_authors(
                       attributes: origin_attributes,
                       original_proposal:,
                       action_user:
                     )
                   else
                     create(
                       attributes: origin_attributes,
                       author:,
                       user_group_author:,
                       action_user:
                     )
                   end

        proposal.link_resources(original_proposal, "copied_from_component") unless skip_link
        copy_attachments(original_proposal, proposal)

        proposal
      end
      # rubocop:enable Metrics/ParameterLists

      module_function :copy

      def copy_attachments(original_proposal, proposal)
        original_proposal.attachments.each do |attachment|
          new_attachment = Decidim::Attachment.new(
            {
              # Attached to needs to be always defined before the file is set
              attached_to: proposal
            }.merge(
              attachment.attributes.slice("content_type", "description", "file_size", "title", "weight")
            )
          )

          if attachment.file.attached?
            new_attachment.file = attachment.file.blob
          else
            new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file).url(host: original_proposal.organization.host)
          end

          new_attachment.save!
        rescue Errno::ENOENT, OpenURI::HTTPError => e
          Rails.logger.warn("[ERROR] Couldn't copy attachment from proposal #{original_proposal.id} when copying to component due to #{e.message}")
        end
      end

      module_function :copy_attachments
    end
  end
end
