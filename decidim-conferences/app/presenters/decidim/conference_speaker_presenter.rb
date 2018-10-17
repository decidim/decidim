# frozen_string_literal: true

module Decidim
  #
  # Decorator for conference speakers
  #
  class ConferenceSpeakerPresenter < SimpleDelegator
    include Decidim::ResourceHelper

    delegate :profile_path, to: :user, allow_nil: true

    def name
      user ? user.name : full_name
    end

    def nickname
      user.nickname if user
    end

    private

    def user
      @user ||= begin
        if (user = __getobj__.user.presence)
          Decidim::UserPresenter.new(user)
        end
      end
    end
  end
end
