# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # member in the system.
      class CreateAssemblyMember < Decidim::Commands::CreateResource
        fetch_file_attributes :non_user_avatar

        fetch_form_attributes :full_name, :gender, :birthday, :birthplace, :ceased_date, :designation_date,
                              :position, :position_other, :user

        protected

        def run_after_hooks
          notify_assembly_member_about_new_membership
        end

        private

        def attributes
          super.merge(assembly: form.participatory_space)
        end

        def resource_class = Decidim::AssemblyMember

        def extra_params
          {
            resource: {
              title: form.full_name
            },
            participatory_space: {
              title: form.participatory_space.title
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
            resource: form.participatory_space,
            followers:
          }
          Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
