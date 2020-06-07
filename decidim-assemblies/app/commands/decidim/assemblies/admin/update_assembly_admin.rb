# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updated a participatory
      # process admin in the system.
      class UpdateAssemblyAdmin < NotifyRoleAssignedToAssembly
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # user_role - The AssemblyUSerRole to update
        def initialize(form, user_role)
          @form = form
          @user_role = user_role
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless user_role

          update_role!
          broadcast(:ok)
        end

        private

        attr_reader :form, :user_role

        def update_role!
          log_info = {
            resource: {
              title: user_role.user.name
            }
          }
          Decidim.traceability.update!(
            user_role,
            form.current_user,
            { role: form.role },
            log_info
          )
          send_notification user_role.user
        end
      end
    end
  end
end
