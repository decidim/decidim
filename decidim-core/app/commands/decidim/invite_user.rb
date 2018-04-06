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
        update_user
      else
        invite_user
      end

      broadcast(:ok, user)
    end

    private

    attr_reader :form

    def user
      # rubocop:disable Rails/FindBy
      @user ||= Decidim::User.where(organization: form.organization).where(email: form.email.downcase).first
      # rubocop:enable Rails/FindBy
    end

    def update_user
      user.admin = form.role == "admin"
      user.roles << form.role if form.role != "admin"
      user.roles = user.roles.uniq.compact
      user.save!
    end

    def invite_user
      @user = Decidim::User.new(
        name: form.name,
        email: form.email.downcase,
        nickname: User.nicknamize(form.name),
        organization: form.organization,
        admin: form.role == "admin",
        roles: form.role == "admin" ? [] : [form.role].compact
      )
      @user.invite!(
        form.invited_by,
        invitation_instructions: form.invitation_instructions
      )
    end
  end
end
