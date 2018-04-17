# frozen_string_literal: true

module Decidim
  module Consultations
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer consultations.
        # Intended to be used with `cancancan`.
        class ConsultationAdminAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user&.admin?

            @user = user
            @context = context

            can :manage, Consultation

            cannot :publish_results, Consultation
            can :publish_results, Consultation do |consultation|
              consultation.finished? && !consultation.results_published?
            end

            cannot :unpublish_results, Consultation
            can :unpublish_results, Consultation, &:results_published?
          end
        end
      end
    end
  end
end
