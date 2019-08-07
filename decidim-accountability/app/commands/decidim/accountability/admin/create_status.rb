# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Status from the admin
      # panel.
      class CreateStatus < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the status if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_status
          end

          broadcast(:ok)
        end

        private

        attr_reader :status

        def create_status
          @status = Status.create!(
            component: @form.current_component,
            key: @form.key,
            name: @form.name,
            description: @form.description,
            progress: @form.progress
          )
        end
      end
    end
  end
end
