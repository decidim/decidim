# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating an assembly
      # member in the system.
      class UpdateAssemblyMember < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

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

          assembly_member.assign_attributes(attributes)

          if assembly_member.valid?
            assembly_member.reload
            update_assembly_member!
            broadcast(:ok)
          else
            if assembly_member.errors.include? :non_user_avatar
              form.errors.add(
                :non_user_avatar,
                assembly_member.errors[:non_user_avatar]
              )
            end

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :assembly_member

        def attributes
          form.attributes.slice(
            "full_name",
            "gender",
            "birthday",
            "birthplace",
            "ceased_date",
            "designation_date",
            "position",
            "position_other",
            "weight"
          ).symbolize_keys.merge(
            user: form.user
          ).merge(
            attachment_attributes(:non_user_avatar)
          )
        end

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
            attributes,
            log_info
          )
        end
      end
    end
  end
end
