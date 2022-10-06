# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Status from the admin
      # panel.
      class CreateStatus < Decidim::Command
        def initialize(form, user)
          @form = form
          @user = user
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
          @status = Decidim.traceability.create!(
            Status,
            @user,
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
