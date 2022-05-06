# frozen_string_literal: true

module Decidim
  #
  # Decorator for assembly members
  #
  class AssemblyMemberPresenter < SimpleDelegator
    def age
      (Time.current.strftime("%Y%m%d").to_i - birthday.strftime("%Y%m%d").to_i) / 10_000 if birthday
    end

    delegate :profile_url, :avatar_url, to: :user, allow_nil: true

    def name
      user ? user.name : full_name
    end

    def nickname
      user.nickname if user
    end

    def personal_information
      [
        gender.presence,
        age,
        birthplace.presence
      ].compact.join(" / ")
    end

    def position
      return position_other if __getobj__.position == "other"

      I18n.t(__getobj__.position, scope: "decidim.admin.models.assembly_member.positions", default: "")
    end

    def non_user_avatar_path
      return non_user_avatar.default_url unless non_user_avatar.attached?

      non_user_avatar.path
    end

    def non_user_avatar
      attached_uploader(:non_user_avatar)
    end

    private

    def user
      @user ||= if (user = __getobj__.user.presence)
                  Decidim::UserPresenter.new(user)
                end
    end
  end
end
