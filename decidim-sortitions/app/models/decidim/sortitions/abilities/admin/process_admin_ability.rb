# frozen_string_literal: true

module Decidim
  module Sortitions
    module Abilities
      module Admin
        class ProcessAdminAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user
            return if user.admin?

            @user = user
            @context = context

            return unless process_administrator?

            can :manage, Sortition
            cannot :destroy, Sortition
            can :destroy, Sortition do |sortition|
              !sortition.cancelled?
            end
          end

          private

          def process_administrator?
            return false unless current_participatory_space.is_a? Decidim::ParticipatoryProcess

            Decidim::ParticipatoryProcesses::Admin::AdminUsers
              .for(current_participatory_space)
              .where(id: user.id)
              .any?
          end

          def current_participatory_space
            @current_participatory_space ||= @context[:current_participatory_space]
          end
        end
      end
    end
  end
end
