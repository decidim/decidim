# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # member in the system.
      class CreateAssemblyMember < Decidim::Commands::CreateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :full_name, :gender, :birthday, :birthplace, :ceased_date, :designation_date,
                              :position, :position_other, :user

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - The Assembly that will hold the member
        def initialize(form, assembly)
          super(form)
          @assembly = assembly
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if assembly_member_with_attributes.valid?
            create_resource
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

        attr_reader :assembly

        def attributes
          super.merge(assembly:).merge(attachment_attributes(:non_user_avatar))
        end

        def assembly_member_with_attributes
          @assembly_member_with_attributes ||= Decidim::AssemblyMember.new(**attributes)
        end

        def resource_class = Decidim::AssemblyMember

        def extra_params
          {
            resource: {
              title: form.full_name
            },
            participatory_space: {
              title: assembly.title
            }
          }
        end

        def followers
          form.user.is_a?(Decidim::UserGroup) ? form.user.users : [form.user]
        end

        def notify_assembly_member_about_new_membership
          data = {
            event: "decidim.events.assemblies.create_assembly_member",
            event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
            resource: assembly,
            followers:
          }
          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
