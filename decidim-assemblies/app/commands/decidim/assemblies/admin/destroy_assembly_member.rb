# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when destroying an assembly
      # member in the system.
      class DestroyAssemblyMember < Rectify::Command
        # Public: Initializes the command.
        #
        # assembly_member - the AssemblyMember to destroy
        # current_user - the user performing this action
        def initialize(assembly_member, current_user)
          @assembly_member = assembly_member
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_member!
          broadcast(:ok)
        end

        private

        attr_reader :assembly_member, :current_user

        def destroy_member!
          log_info = {
            resource: {
              title: assembly_member.full_name
            },
            participatory_space: {
              title: assembly_member.assembly.title
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            assembly_member,
            current_user,
            log_info
          ) do
            assembly_member.destroy!
            assembly_member
          end
        end
      end
    end
  end
end
