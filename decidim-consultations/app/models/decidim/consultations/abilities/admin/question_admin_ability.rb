# frozen_string_literal: true

module Decidim
  module Consultations
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer consultation's questions.
        # Intended to be used with `cancancan`.
        class QuestionAdminAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user&.admin?

            @user = user
            @context = context

            can :manage, Question
            cannot :publish, Question
            can :publish, Question do |question|
              question.external_voting || question.responses_count.positive?
            end
          end
        end
      end
    end
  end
end
