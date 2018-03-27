# frozen_string_literal: true

module Decidim
  module Consultations
    module Abilities
      # Defines the base abilities related to consultations for any user. Guest
      # users will use these too. Intended to be used with `cancancan`.
      class EveryoneAbility < Decidim::Abilities::EveryoneAbility
        def initialize(user, context)
          super(user, context)

          can :read, Consultation do |consultation|
            consultation.published? || user&.admin?
          end

          can :read, Question do |question|
            question.published? || user&.admin?
          end
        end
      end
    end
  end
end
