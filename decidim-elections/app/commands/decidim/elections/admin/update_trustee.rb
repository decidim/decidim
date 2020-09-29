# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user updates a Trustee
      # from the admin panel.
      class UpdateTrustee < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, trustee)
          @form = form
          @trustee = trustee
        end

        # Creates the trustee if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_trustee!

          broadcast(:ok)
        end

        private

        attr_reader :form, :trustee

        def participatory_space_to_update
          trustee.trustees_participatory_spaces.where(participatory_space: form.current_participatory_space)
        end

        def update_trustee!
          participatory_space_to_update.update(
            considered: form.considered
          )
        end
      end
    end
  end
end
