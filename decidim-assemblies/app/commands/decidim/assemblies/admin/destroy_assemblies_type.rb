# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when destroying an assembly
      # type in the system.
      class DestroyAssembliesType < Rectify::Command
        # Public: Initializes the command.
        #
        # assemblies_type - the AssemblyMember to destroy
        def initialize(assemblies_type)
          @assemblies_type = assemblies_type
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          @assemblies_type.destroy!
          broadcast(:ok)
        end
      end
    end
  end
end
