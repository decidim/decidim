# frozen_string_literal: true

module Decidim
  #
  # Decorator for assembly members
  #
  class ParticipatorySpacePrivateUserPresenter < SimpleDelegator
    delegate :profile_url, to: :user, allow_nil: true

    def name
      user ? user.name : full_name
    end

    def nickname
      user.nickname if user
    end

    def avatar_url(variant = nil)
      return user.avatar_url(variant) if user.present?

      non_user_avatar_path(variant)
    end

    def non_user_avatar_path(variant = nil)
      return non_user_avatar.default_url(variant) unless non_user_avatar.attached?

      non_user_avatar.path(variant:)
    end

    def non_user_avatar
      attached_uploader(:non_user_avatar)
    end

    def deleted?
      false
    end

    private

    def user
      @user ||= if (user = __getobj__.user.presence)
                  Decidim::UserPresenter.new(user)
                end
    end
  end
end
