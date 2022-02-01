# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      # Command that cancels a sortition
      class DestroySortition < Decidim::Command
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

          destroy_sortition
          broadcast(:ok, sortition)
        end

        private

        attr_reader :form

        def destroy_sortition
          Decidim.traceability.perform_action!(
            :delete,
            sortition,
            form.current_user
          ) do
            sortition.update(
              cancel_reason: form.cancel_reason,
              cancelled_on: Time.now.utc,
              cancelled_by_user: form.current_user
            )
          end
        end

        def sortition
          @sortition ||= Sortition.find(form.id)
        end
      end
    end
  end
end
