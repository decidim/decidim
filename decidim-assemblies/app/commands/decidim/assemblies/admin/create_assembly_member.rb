# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # member in the system.
      class CreateAssemblyMember < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

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

          if assembly_member_with_attributes.valid?
            create_assembly_member!
            notify_assembly_member_about_new_membership

            broadcast(:ok)
          else
            if assembly_member_with_attributes.errors.include? :non_user_avatar
              form.errors.add(
                :non_user_avatar,
                assembly_member_with_attributes.errors[:non_user_avatar]
              )
            end
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :assembly, :current_user

        def assembly_member_with_attributes
          @assembly_member_with_attributes ||= Decidim::AssemblyMember.new(assembly_member_attributes)
        end

        def assembly_member_attributes
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
            assembly: assembly,
            user: form.user
          ).merge(
            attachment_attributes(:non_user_avatar)
          )
        end

        def create_assembly_member!
          log_info = {
            resource: {
              title: form.full_name
            },
            participatory_space: {
              title: assembly.title
            }
          }

          @assembly_member = Decidim.traceability.create!(
            Decidim::AssemblyMember,
            current_user,
            assembly_member_attributes,
            log_info
          )
        end

        def followers
          form.user.is_a?(Decidim::UserGroup) ? form.user.users : [form.user]
        end

        def notify_assembly_member_about_new_membership
          data = {
            event: "decidim.events.assemblies.create_assembly_member",
            event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
            resource: assembly,
            followers: followers
          }
          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
