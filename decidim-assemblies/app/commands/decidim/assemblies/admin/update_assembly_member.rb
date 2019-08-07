# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating an assembly
      # member in the system.
      class UpdateAssemblyMember < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly_member - The AssemblyMember to update
        def initialize(form, assembly_member)
          @form = form
          @assembly_member = assembly_member
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless assembly_member

          update_assembly_member!
          broadcast(:ok)
        end

        private

        attr_reader :form, :assembly_member

        def update_assembly_member!
          log_info = {
            resource: {
              title: assembly_member.full_name
            },
            participatory_space: {
              title: assembly_member.assembly.title
            }
          }

          Decidim.traceability.update!(
            assembly_member,
            form.current_user,
            form.attributes.slice(
              :full_name,
              :gender,
              :birthday,
              :birthplace,
              :ceased_date,
              :designation_date,
              :designation_mode,
              :position,
              :position_other,
              :weight
            ).merge(
              user: form.user
            ),
            log_info
          )
        end
      end
    end
  end
end
