# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer initiatives.
        # Intended to be used with `cancancan`.
        class InitiativeAdminAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user&.admin?

            @user = user
            @context = context

            define_admin_abilities
          end

          private

          def define_admin_abilities
            can :preview, Initiative

            can :manage, Initiative
            can :send_to_technical_validation, Initiative
            cannot :show, Initiative
            can :show, Initiative if Decidim::Initiatives.print_enabled

            cannot :publish, Initiative
            can :publish, Initiative, &:validating?

            cannot :unpublish, Initiative
            can :unpublish, Initiative, &:published?

            cannot :discard, Initiative
            can :discard, Initiative, &:validating?

            cannot :accept, Initiative
            can :accept, Initiative do |initiative|
              initiative.published? &&
                initiative.signature_end_time < Time.zone.today &&
                initiative.percentage >= 100
            end

            cannot :reject, Initiative
            can :reject, Initiative do |initiative|
              initiative.published? &&
                initiative.signature_end_time < Time.zone.today &&
                initiative.percentage < 100
            end

            cannot :export_votes, Initiative
            can :export_votes, Initiative do |initiative|
              initiative.offline? || initiative.any?
            end
          end
        end
      end
    end
  end
end
