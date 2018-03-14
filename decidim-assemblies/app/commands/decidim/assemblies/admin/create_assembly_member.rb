# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # member in the system.
      class CreateAssemblyMember < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - The Assembly that will hold the member
        def initialize(form, current_user, assembly)
          @form = form
          @current_user = current_user
          @assembly = assembly
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_assembly_member!
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :assembly, :current_user, :user

        def create_assembly_member!
          @assembly_member = Decidim.traceability.create!(
            Decidim::AssemblyMember,
            current_user,
            form.attributes.slice(
              :full_name,
              :gender,
              :origin,
              :birthday,
              :designation_date,
              :designation_mode,
              :position,
              :position_other
            ).merge(
              assembly: assembly
            )
          )
        end
      end
    end
  end
end
