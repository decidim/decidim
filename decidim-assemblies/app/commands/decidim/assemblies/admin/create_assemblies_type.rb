# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # type in the system.
      class CreateAssembliesType < Decidim::Command
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

          create_assemblies_type!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def create_assemblies_type!
          Decidim.traceability.create!(
            AssembliesType,
            form.current_user,
            organization: form.current_organization,
            title: form.title
          )
        end
      end
    end
  end
end
