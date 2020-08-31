# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating assemblies
      # settings in admin area.
      class UpdateAssembliesSetting < Rectify::Command
        # Public: Initializes the command.
        #
        # assemblies_setting - A assemblies_setting object to update.
        # form - A form object with the params.
        def initialize(assemblies_settings, form)
          @assemblies_settings = assemblies_settings
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form or assemblies_settings isn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || assemblies_settings.invalid?

          update_assemblies_setting!

          broadcast(:ok)
        end

        private

        attr_reader :form, :assemblies_settings

        def update_assemblies_setting!
          Decidim.traceability.update!(
            @assemblies_settings,
            form.current_user,
            enable_organization_chart: form.enable_organization_chart
          )
        end
      end
    end
  end
end
