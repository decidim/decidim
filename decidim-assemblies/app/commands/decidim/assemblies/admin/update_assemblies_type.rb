# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating a new assembly
      # type in the system.
      class UpdateAssembliesType < Decidim::Command
        # Public: Initializes the command.
        #
        # assemblies_type - A assemblies_type object to update.
        # form - A form object with the params.
        def initialize(assemblies_type, form)
          @assemblies_type = assemblies_type
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

          update_assemblies_type!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_assemblies_type!
          Decidim.traceability.update!(
            @assemblies_type,
            form.current_user,
            title: form.title
          )
        end
      end
    end
  end
end
