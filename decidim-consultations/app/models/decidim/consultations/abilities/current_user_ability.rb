# frozen_string_literal: true

module Decidim
  module Consultations
    module Abilities
      # Defines the base abilities related to consultations and questions for
      # authenticated users. Intended to be used with `cancancan`.
      class CurrentUserAbility < Decidim::Abilities::EveryoneAbility
        attr_reader :user

        def initialize(user, context)
          super(user, context)
          return unless user

          @user = user

          can :vote, Question do |question|
            can_vote?(question)
          end

          can :unvote, Question do |question|
            can_unvote?(question)
          end
        end

        private

        def can_vote?(question)
          question.organization.id == user.organization.id &&
            question.consultation.active? &&
            question.consultation.published? &&
            question.published? &&
            !question.voted_by?(user)
        end

        def can_unvote?(question)
          question.consultation.active? &&
            question.consultation.published? &&
            question.published? &&
            question.voted_by?(user)
        end
      end
    end
  end
end
