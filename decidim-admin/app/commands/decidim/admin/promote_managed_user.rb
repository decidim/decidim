# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to promote a managed user.
    #
    # Managed users can be promoted to standard users. It means they
    # will be invited to the application and will lose the managed flag
    # so the user cannot be impersonated anymore.
    class PromoteManagedUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # user         - The user to promote
      # promoted_by  - The user performing the operation
      def initialize(form, user, promoted_by)
        @form = form
        @user = user
        @promoted_by = promoted_by
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid? || !user.managed? || email_already_exists?

        promote_user
        invite_user

        broadcast(:ok)
      end

      attr_reader :form, :user, :promoted_by

      private

      def promote_user
        user.email = form.email.downcase
        user.skip_reconfirmation!
        user.save(validate: false)
      end

      def invite_user
        user.invite!(promoted_by)
      end

      def email_already_exists?
        Decidim::User.where(email: form.email.downcase).any?
      end
    end
  end
end
