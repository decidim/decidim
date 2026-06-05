# frozen_string_literal: true

module Decidim
  module Admin
    #
    # Decorator for conference speakers
    #
    class ConferenceSpeakerPresenter < SimpleDelegator
      def name
        if user
          "#{user.name} (#{user.nickname})"
        else
          full_name
        end
      end

      private

      def user
        @user ||= if (user = __getobj__.user.presence)
                    Decidim::UserPresenter.new(user)
                  end
      end
    end
  end
end
