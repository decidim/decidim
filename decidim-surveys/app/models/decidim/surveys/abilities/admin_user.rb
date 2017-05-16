# frozen_string_literal: true
module Decidim
  module Surveys
    module Abilities
      # Defines the abilities related to surveys for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminUser
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user && user.role?(:admin)

          @user = user
          @context = context

          can :manage, Survey
        end

        private

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def feature_settings
          context.fetch(:feature_settings, nil)
        end
      end
    end
  end
end
