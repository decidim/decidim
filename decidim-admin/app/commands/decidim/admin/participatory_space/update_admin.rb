# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      class UpdateAdmin < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # user_role - The UserRole to update
        # options: a hash with at least two mandatory keys, event_class and event
        # - event_class - The event class to be used when notifying the user
        # - event - The event name to be used when notifying the user
        def initialize(form, user_role, options = {})
          @form = form
          @user_role = user_role
          @event_class = options.delete(:event_class)
          @event = options.delete(:event)
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

        def event_class = @event_class || (raise NotImplementedError, "You must define an event_class")

        def event = @event || (raise NotImplementedError, "You must define an event")

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
