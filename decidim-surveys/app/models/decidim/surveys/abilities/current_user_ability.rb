# frozen_string_literal: true

module Decidim
  module Surveys
    module Abilities
      # Defines the abilities related to surveys for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :answer, Survey if authorized?(:answer)
        end

        private

        def authorized?(action)
          return unless feature

          ActionAuthorizer.new(user, feature, action).authorize.ok?
        end

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def feature_settings
          context.fetch(:feature_settings, nil)
        end

        def feature
          feature = context.fetch(:current_feature, nil)
          return nil unless feature&.manifest&.name == :surveys

          feature
        end
      end
    end
  end
end
