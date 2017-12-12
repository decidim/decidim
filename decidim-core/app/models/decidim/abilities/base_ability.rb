# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a User. Intended to be used with `cancancan`.
    class BaseAbility
      include CanCan::Ability

      # Initializes the ability class for the given user. Automatically merges
      # injected abilities fmor the configuration. In order to inject more
      # abilities, add this code in the `engine.rb` file of your own engine, for
      # example, inside an initializer:
      #
      #   Decidim.configure do |config|
      #     config.abilities << Decidim::MyEngine::Abilities::MyAbility
      #   end
      #
      # Note that, in development, this will force you to restart the server
      # every time you change things in your ability classes.
      #
      # user - the User that needs its abilities checked.
      # context - a Hash with some context related to the current request.
      def initialize(user, context = {})
        Decidim.abilities.each do |ability|
          merge ability.constantize.new(user, context)
        end

        can :create, Authorization do |authorization|
          authorization.user == user && not_already_active?(user, authorization)
        end

        can :update, Authorization do |authorization|
          authorization.user == user && !authorization.granted?
        end

        can :manage, Follow do |follow|
          follow.user == user
        end

        can :manage, Notification do |notification|
          notification.user == user
        end

        can :manage, Messaging::Conversation do |conversation|
          conversation.participants.include?(user)
        end
      end

      private

      def not_already_active?(user, authorization)
        Verifications::Authorizations.new(user: user, name: authorization.name).none?
      end
    end
  end
end
