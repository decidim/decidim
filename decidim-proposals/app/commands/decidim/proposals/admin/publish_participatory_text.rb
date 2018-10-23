# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # a participatory text.
      class PublishParticipatoryText < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
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
            resort_proposals(form)
            publish_drafts
          end

          if @publish_failures.any?
            broadcast(:invalid, @publish_failures)
          else
            broadcast(:ok)
          end
        end

        private

        attr_reader :form
        attr_reader :publish_failures

        def resort_proposals(form)
          form.proposals.each do |prop_form|
            proposal = Decidim::Proposals::Proposal.where(component: current_component).find(prop_form.id)
            proposal.set_list_position(prop_form.position) if proposal.position != prop_form.position
          end
        end

        def publish_drafts
          @publish_failures = {}
          Decidim::Proposals::Proposal.where(component: current_component).drafts.find_each do |proposal|
            @publish_failures[proposal.id] = proposal.errors.full_messages unless proposal.update(published_at: Time.current)
          end
          raise ActiveRecord::Rollback if @publish_failures.any?
        end
      end
    end
  end
end
