# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin merges proposals from
      # one component to another.
      class MergeProposals < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          if process_attachments?
            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            merged_proposals
          end

          broadcast(:ok, @merge_proposal)
        end

        private

        attr_reader :form, :attachment, :gallery

        def merged_proposals
          @merged_proposal = create_new_proposal
          merge_authors
          @merged_proposal.link_resources(proposals_to_link, "merged_from_component")
          proposals_mark_as_withdrawn if form.same_component?
          @attached_to = @merged_proposal
          create_gallery if process_gallery?
          create_attachment(weight: first_attachment_weight) if process_attachments?
          link_author_meeting if form.created_in_meeting?
          notify_author
        end

        def proposals_mark_as_withdrawn
          form.proposals.each do |proposal|
            proposal.update!(withdrawn_at: Time.current)
          end
        end

        def proposals_to_link
          form.proposals
        end

        def previous_links
          @previous_links ||= form.proposals.flat_map do |proposal|
            proposal.linked_resources(:proposals, "merged_from_component")
          end
        end

        def create_new_proposal
          original_proposal = form.proposals.first

          Decidim::Proposals::ProposalBuilder.copy(
            original_proposal,
            author: form.current_organization,
            action_user: form.current_user,
            extra_attributes: {
              component: form.target_component,
              title: form.title,
              body: form.body,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              created_in_meeting: form.created_in_meeting
            },
            skip_link: true
          )
        end

        def merge_authors
          add_organization_as_first_author

          form.proposals.each do |proposal|
            proposal.authors.each do |author|
              @merged_proposal.add_coauthor(author)
            end
          end
        end

        def add_organization_as_first_author
          organization = form.current_organization
          @merged_proposal.add_coauthor(organization) unless @merged_proposal.authors.include?(organization)
        end

        def notify_author
          return unless @merged_proposal.coauthorships.any?

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_merged",
            event_class: Decidim::Proposals::MergedProposalEvent,
            resource: @merged_proposal,
            affected_users: @merged_proposal.notifiable_identities
          )
        end

        def first_attachment_weight
          return 1 if @merged_proposal.photos.count.zero?

          @merged_proposal.photos.count
        end

        def link_author_meeting
          @merged_proposal.link_resources(form.author, "proposals_from_meeting")
        end
      end
    end
  end
end
