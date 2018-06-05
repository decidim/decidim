# frozen_string_literal: true

module Decidim
  # This command invites some user friends.
  class InviteFriends < Rectify::Command
    # Invites the user friends
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?
      invite_friends
      broadcast(:ok)
    end

    private

    attr_reader :form

    def invite_friends
      cleaned_emails.each do |email|
        InviteUser.call(build_invite_form(email)) do
          on(:ok) do |user|
            return user
          end
        end
      end
    end

    def build_invite_form(email)
      OpenStruct.new(
        name: email.downcase.split("@").first,
        email: email.downcase,
        organization: form.current_organization,
        admin: false,
        role: nil,
        invited_by: form.current_user,
        invitation_instructions: "invite_admin"
      )
    end

    def cleaned_emails
      existing_emails = Decidim::User.where(organization: form.current_organization, email: form.emails).pluck(:email)
      form.emails - existing_emails
    end
  end
end
