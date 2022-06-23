# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic when updating initiatives
      # settings in admin area.
      class UpdateInitiativesSettings < Decidim::Command
        # Public: Initializes the command.
        #
        # initiatives_settings - A initiatives settings object to update.
        # form - A form object with the params.
        def initialize(initiatives_settings, form)
          @initiatives_settings = initiatives_settings
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form or initiatives_settings isn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || initiatives_settings.invalid?

          update_initiatives_settings!

          broadcast(:ok)
        end

        private

        attr_reader :form, :initiatives_settings

        def update_initiatives_settings!
          Decidim.traceability.update!(
            @initiatives_settings,
            form.current_user,
            initiatives_order: form.initiatives_order
          )
        end
      end
    end
  end
end
