# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to plain users able to administer initiatives.
        # Intended to be used with `cancancan`.
        class InitiativeUserAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user
            return if user&.admin?

            @user = user
            @context = context

            grant_dashboard_access
            grant_initiative_permissions
          end

          private

          def grant_dashboard_access
            can :read, :admin_dashboard if has_initiatives?(user)
          end

          def grant_initiative_permissions
            can :list, Decidim::Initiative if has_initiatives?(user)

            can :preview, Initiative do |initiative|
              initiative.has_authorship? user
            end

            can :read, Initiative do |initiative|
              initiative.has_authorship?(user) &&
                Decidim::Initiatives.print_enabled
            end

            can :edit, Decidim::Initiative do |initiative|
              initiative.has_authorship?(user)
            end

            can :update, Decidim::Initiative do |initiative|
              initiative.has_authorship?(user) && initiative.created?
            end

            can :send_to_technical_validation, Initiative do |initiative|
              initiative.has_authorship?(user) &&
                initiative.created? && (
                  !initiative.decidim_user_group_id.nil? ||
                    initiative.committee_members.approved.count >= Decidim::Initiatives.minimum_committee_members
                )
            end
          end

          def has_initiatives?(user)
            initiatives = InitiativesCreated.by(user) | InitiativesPromoted.by(user)
            initiatives.any?
          end
        end
      end
    end
  end
end
