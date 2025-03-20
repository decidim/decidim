# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind creating a user group.
  class InviteUserToGroupForm < Form
    mimic :invite

    attribute :nickname, String

    validates :nickname, presence: true
    validate :user_exists

    def user
      @user ||= Decidim::User.find_by(nickname: clean_nickname, organization: current_organization)
    end

    private

    def clean_nickname
      nickname.to_s.tr("@", "")
    end

    def user_exists
      return true if user.present?

      errors.add :nickname, :invalid
    end
  end
end
