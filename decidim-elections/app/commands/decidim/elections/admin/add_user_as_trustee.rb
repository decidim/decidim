# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the admin user creates a trustee
      # from the admin panel.
      class AddUserAsTrustee < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, current_user)
          @form = form
          @current_user = current_user
        end

        # Creates the trustee if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:exists) if existing_trustee_participatory_spaces?

          transaction do
            add_user_as_trustee! if new_trustee?
            add_participatory_space
            notify_user_about_trustee_role if new_trustee?
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :trustee

        def add_user_as_trustee!
          @trustee = Decidim.traceability.create!(
            Trustee,
            form.current_user,
            user: form.user
          )
        end

        # If a trustee exists for this participatory space, it won't get created again
        def existing_trustee_participatory_spaces?
          trustees_space = TrusteesParticipatorySpace.where(participatory_space: form.current_participatory_space).includes(:trustee)
          @existing_trustee_participatory_spaces ||= Decidim::Elections::Trustee.joins(:trustees_participatory_spaces)
                                                                                .includes([:user])
                                                                                .where(trustees_participatory_spaces: trustees_space)
                                                                                .where(decidim_user_id: form.user.id).any?
        end

        # if there's no user - trustee relation, the trustee gets created and the notification
        # gets send.
        def new_trustee?
          return @new_trustee if defined?(@new_trustee)

          @new_trustee = Decidim::Elections::Trustee.where(decidim_user_id: form.user.id).empty?
        end

        def add_participatory_space
          trustee = Decidim::Elections::Trustee.find_by(decidim_user_id: form.user.id)
          trustee.trustees_participatory_spaces.create!(
            participatory_space: form.current_participatory_space
          )
        end

        def notify_user_about_trustee_role
          data = {
            event: "decidim.events.elections.trustees.new_trustee",
            event_class: Decidim::Elections::Trustees::NotifyNewTrusteeEvent,
            resource: form.current_participatory_space,
            affected_users: [form.user]
          }
          Decidim::EventsManager.publish(data)
        end
      end
    end
  end
end
