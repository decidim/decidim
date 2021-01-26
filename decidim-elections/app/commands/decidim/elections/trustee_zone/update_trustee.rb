# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This command allows the user to update their trustee information
      class UpdateTrustee < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form with the new trustee information
        def initialize(form)
          @form = form
        end

        # Update the trustee if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_trustee!

          broadcast(:ok, trustee)
        end

        private

        attr_reader :form

        delegate :trustee, to: :form

        def update_trustee!
          trustee.update!(
            name: form.name,
            public_key: form.public_key
          )
        end
      end
    end
  end
end
