# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      class UpdateAdmin < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # user_role - The UserRole to update
        def initialize(form, user_role)
          @form = form
          @user_role = user_role
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
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

        def event = raise NotImplementedError, "Event method must be implemented for #{self.class.name}"

        def event_class = raise NotImplementedError, "Event class method must be implemented for #{self.class.name}"

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

        def send_notification(user)
          Decidim::EventsManager.publish(
            event:,
            event_class:,
            resource: form.current_participatory_space,
            affected_users: [user],
            extra: {
              role: form.role
            }
          )
        end
      end
    end
  end
end
