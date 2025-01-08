# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin merges proposals from
      # one component to another.
      class MergeProposals < Decidim::Command
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

          merge_proposals

          broadcast(:ok, @merge_proposal)
        end

        private

        attr_reader :form

        def merge_proposals
          transaction do
            @merged_proposal = create_new_proposal
            merge_authors
            @merged_proposal.link_resources(proposals_to_link, "merged_from_component")
            form.proposals.each(&:destroy!) if form.same_component?
            notify_author
          end
        end

        def proposals_to_link
          return previous_links if form.same_component?

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
              body: form.body
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
      end
    end
  end
end
