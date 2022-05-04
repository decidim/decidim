# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the admin user creates a trustee
      # from the admin panel.
      class AddUserAsTrustee < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, current_user)
          @form = form
          @user = form.user
          @participatory_space = form.current_participatory_space
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

          send_email

          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :trustee, :participatory_space, :user

        def add_user_as_trustee!
          @trustee = Decidim.traceability.create!(
            Trustee,
            current_user,
            user: user,
            organization: user.organization
          )
        end

        # If a trustee exists for this participatory space, it won't get created again
        def existing_trustee_participatory_spaces?
          trustees_space = TrusteesParticipatorySpace.where(participatory_space: participatory_space).includes(:trustee)
          @existing_trustee_participatory_spaces ||= Decidim::Elections::Trustee.joins(:trustees_participatory_spaces)
                                                                                .includes([:user])
                                                                                .where(trustees_participatory_spaces: trustees_space)
                                                                                .where(decidim_user_id: user.id).any?
        end

        # if there's no user - trustee relation, the trustee gets created and the notification
        # gets send.
        def new_trustee?
          return @new_trustee if defined?(@new_trustee)

          @new_trustee = Decidim::Elections::Trustee.where(decidim_user_id: user.id).empty?
        end

        def add_participatory_space
          trustee = Decidim::Elections::Trustee.find_by(decidim_user_id: user.id)
          trustee.trustees_participatory_spaces.create!(
            participatory_space: participatory_space
          )
        end

        def notify_user_about_trustee_role
          data = {
            event: "decidim.events.elections.trustees.new_trustee",
            event_class: Decidim::Elections::Trustees::NotifyNewTrusteeEvent,
            resource: participatory_space,
            affected_users: [user]
          }
          Decidim::EventsManager.publish(**data)
        end

        def send_email
          Decidim::Elections::TrusteeMailer.notification(
            user, participatory_space, I18n.locale.to_s
          ).deliver_later
        end
      end
    end
  end
end
