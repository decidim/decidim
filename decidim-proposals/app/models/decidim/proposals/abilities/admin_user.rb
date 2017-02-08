# frozen_string_literal: true
module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminUser
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user && user.role?(:admin)

          @user = user
          @context = context

          can :manage, Proposal
          cannot :create, Proposal unless can_create_proposal?
        end

        private

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def feature_settings
          context.fetch(:feature_settings, nil)
        end

        def can_create_proposal?
          current_settings.try(:creation_enabled?) &&
            feature_settings.try(:official_proposals_enabled)
        end
      end
    end
  end
end
