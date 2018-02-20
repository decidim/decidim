# frozen_string_literal: true

module Decidim
  module Admin
    # A command to invite an admin.
    class InviteAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          invite_user
          set_nickname
          log_action
        end

        broadcast(:ok)
      end

      private

      attr_reader :user, :form

      def invite_user
        InviteUser.call(form) do
          on(:ok) do |user|
            set_user(user)
          end
        end
      end

      def set_nickname
        user.update_attributes(nickname: User.nicknamize(user.name))
      end

      def set_user(user)
        @user = user
      end

      def log_action
        Decidim::ActionLogger.log(
          "invite",
          form.current_user,
          user,
          extra: {
            invited_user_role: form.role,
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
