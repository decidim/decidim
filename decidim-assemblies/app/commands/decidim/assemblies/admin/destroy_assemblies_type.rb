# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when destroying an assembly
      # type in the system.
      class DestroyAssembliesType < Decidim::Command
        # Public: Initializes the command.
        #
        # assemblies_type - the AssemblyMember to destroy
        # current_user - the user performing the action
        def initialize(assemblies_type, current_user)
          @assemblies_type = assemblies_type
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_assembly_type!
          broadcast(:ok)
        end

        private

        attr_reader :current_user

        def destroy_assembly_type!
          Decidim.traceability.perform_action!(
            "delete",
            @assemblies_type,
            current_user
          ) do
            @assemblies_type.destroy!
          end
        end
      end
    end
  end
end
