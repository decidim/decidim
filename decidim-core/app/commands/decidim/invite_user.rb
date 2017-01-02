# frozen_string_literal: true
module Decidim
  # A command with the business logic to invite a user to an organization.
  class InviteUser < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if form.invalid?

      if user.present?
        set_user_roles
      else
        invite_user
      end

      broadcast(:ok)
    end

    private

    attr_reader :form

    def user
      @user ||= Decidim::User.where(organization: form.organization).where(email: form.email.downcase).first
    end

    def set_user_roles
      user.roles += form.roles
      user.save!
    end

    def invite_user
      Decidim::User.invite!(
        {
          name: form.name,
          email: form.email.downcase,
          organization: form.organization,
          roles: form.roles
        },
        form.invited_by,
        invitation_instructions: form.invitation_instructions
      )
    end
  end
end
