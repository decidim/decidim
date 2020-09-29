# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user creates a Trustee
      # from the admin panel.
      class AddUserAsTrustee < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, current_user)
          @form = form
          @current_user = current_user
          # @current_participatory_space = current_participatory_space
        end

        # Creates the trustee if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:exists) if existing_trustee?

          transaction do
            notifiy_user_about_trustee_role if new_trustee?
            add_user_as_trustee!
            add_participatory_space
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

        def existing_trustee?
          Decidim::Elections::Trustee.joins(:trustees_participatory_spaces)
                                     .where("decidim_elections_trustees_participatory_spaces.participatory_space_id = ?", form.current_participatory_space.id)
                                     .where("decidim_user_id = ?", form.user.id).any?
        end

        def new_trustee?
          Decidim::Elections::Trustee.where(decidim_user_id: form.user.id).empty?
        end

        def add_participatory_space
          @trustee.trustees_participatory_spaces.create!(
            participatory_space: form.current_participatory_space
          )
        end

        def notifiy_user_about_trustee_role
          data = {
            event: "decidim.events.elections.trustees.new_trustee",
            event_class: Decidim::Elections::Trustees::NotifiyNewTrusteeEvent,
            resource: form.current_participatory_space,
            affected_users: [form.user]
          }
          Decidim::EventsManager.publish(data)
        end
      end
    end
  end
end
