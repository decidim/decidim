# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # a participatory text.
      class PublishParticipatoryText < UpdateParticipatoryText
        # Public: Initializes the command.
        #
        # form - A PreviewParticipatoryTextForm form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          transaction do
            @failures = {}
            update_contents_and_resort_proposals(form)
            publish_drafts
          end

          if @failures.any?
            broadcast(:invalid, @failures)
          else
            broadcast(:ok)
          end
        end

        private

        attr_reader :form

        def publish_drafts
          Decidim::Proposals::Proposal.where(component: form.current_component).drafts.find_each do |proposal|
            add_failure(proposal) unless publish_proposal(proposal)
          end
          raise ActiveRecord::Rollback if @failures.any?
        end

        def add_failure(proposal)
          @failures[proposal.id] = proposal.errors.full_messages
        end

        # This will be the PaperTrail version shown in the version control feature (1 of 1).
        # For an attribute to appear in the new version it has to be reset
        # and reassigned, as PaperTrail only keeps track of object CHANGES.
        def publish_proposal(proposal)
          title, body = reset_proposal_title_and_body(proposal)

          Decidim.traceability.perform_action!(:create, proposal, form.current_user, visibility: "all") do
            proposal.update(title:, body:, published_at: Time.current)
          end
        end

        # Reset the attributes to an empty string and return the old values.
        def reset_proposal_title_and_body(proposal)
          title = proposal.title
          body = proposal.body

          PaperTrail.request(enabled: false) do
            # rubocop:disable Rails/SkipsModelValidations
            proposal.update_columns(
              title: { I18n.locale => "" },
              body: { I18n.locale => "" }
            )
            # rubocop:enable Rails/SkipsModelValidations
          end

          [title, body]
        end
      end
    end
  end
end
