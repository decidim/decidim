# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      # Command that creates a sortition that selects proposals
      class CreateSortition < Decidim::Command
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
          return broadcast(:invalid) if form.invalid?

          ActiveRecord::Base.transaction do
            sortition = create_sortition
            select_proposals_for(sortition)
            send_notification(sortition)

            broadcast(:ok, sortition)
          end
        end

        private

        attr_reader :form

        def create_sortition
          Decidim.traceability.create!(
            Sortition,
            form.current_user,
            component: form.current_component,
            title: form.title,
            decidim_proposals_component_id: form.decidim_proposals_component_id,
            request_timestamp: Time.now.utc,
            author: form.current_user,
            dice: form.dice,
            target_items: form.target_items,
            witnesses: form.witnesses,
            additional_info: form.additional_info,
            selected_proposals: [],
            candidate_proposals: [],
            category:
          )
        end

        def category
          Decidim::Category.find(form.decidim_category_id) if form.decidim_category_id.present?
        end

        def select_proposals_for(sortition)
          draw = Draw.new(sortition)

          sortition.update(
            selected_proposals: draw.results,
            candidate_proposals: draw.proposals.pluck(:id)
          )
        end

        def send_notification(sortition)
          Decidim::EventsManager.publish(
            event: "decidim.events.sortitions.sortition_created",
            event_class: Decidim::Sortitions::CreateSortitionEvent,
            resource: sortition,
            followers: sortition.participatory_space.followers
          )
        end
      end
    end
  end
end
