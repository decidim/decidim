# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      # Command that creates a sortition that selects proposals
      class UpdateSortition < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_sortition
          broadcast(:ok, sortition)
        end

        private

        attr_reader :form

        def update_sortition
          Decidim.traceability.update!(
            sortition,
            form.current_user,
            title: form.title,
            additional_info: form.additional_info
          )
        end

        def sortition
          @sortition ||= Sortition.find(form.id)
        end
      end
    end
  end
end
