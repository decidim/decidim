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

          create_assembly_member!
          notify_assembly_member_about_new_membership

          broadcast(:ok)
        end

        private

        attr_reader :form, :assembly, :current_user

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
              assembly: assembly,
              user: form.user
            ),
            log_info
          )
        end

        def notify_assembly_member_about_new_membership
          data = {
            event: "decidim.events.assemblies.create_assembly_member",
            event_class: Decidim::Assemblies::CreateAssemblyMemberEvent,
            resource: assembly,
            followers: [form.user]
          }
          Decidim::EventsManager.publish(data)
        end
      end
    end
  end
end
