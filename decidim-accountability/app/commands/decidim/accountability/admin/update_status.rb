# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateStatus < Decidim::Command
        # Initializes an UpdateStatus Command.
        #
        # form - The form from which to get the data.
        # status - The current instance of the status to be updated.
        def initialize(form, status, user)
          @form = form
          @status = status
          @user = user
        end

        # Updates the status if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_status
          end

          broadcast(:ok)
        end

        private

        attr_reader :status, :form

        def update_status
          Decidim.traceability.update!(
            status,
            @user,
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
