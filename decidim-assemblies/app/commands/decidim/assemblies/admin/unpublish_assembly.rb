# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command that sets an assembly as unpublished.
      class UnpublishAssembly < Decidim::Command
        # Public: Initializes the command.
        #
        # assembly - A Assembly that will be published
        # current_user - the user performing the action
        def initialize(assembly, current_user)
          @assembly = assembly
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if assembly.nil? || !assembly.published?

          Decidim.traceability.perform_action!("unpublish", assembly, current_user) do
            assembly.unpublish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :assembly, :current_user
      end
    end
  end
end
