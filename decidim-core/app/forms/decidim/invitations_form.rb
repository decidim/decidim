# frozen_string_literal: true

module Decidim
  # This form holds the data for the invitations system.
  class InvitationsForm < Form
    mimic :invitations

    attribute :email_1, String
    attribute :email_2, String
    attribute :email_3, String
    attribute :email_4, String
    attribute :email_5, String
    attribute :email_6, String
    attribute :custom_text, String

    validates :email_1,
              :email_2,
              :email_3,
              :email_4,
              :email_5,
              :email_6,
              "valid_email_2/email": true,
              allow_blank: true
    validates :emails, presence: true

    def emails
      [email_1, email_2, email_3, email_4, email_5, email_6].uniq.select(&:present?)
    end

    def clean_emails
      existing_emails = Decidim::User
                        .where(organization: current_organization, email: emails)
                        .pluck(:email)
      emails - existing_emails
    end
  end
end
