# frozen_string_literal: true

module Decidim
  module Comments
    module Abilities
      # Defines the abilities related to comments for a logged in process admin user.
      # Intended to be used with `cancancan`.
      class ProcessAdminUser
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user && !user.role?(:admin)

          @user = user
          @context = context

          can :manage, Comment do |comment|
            participatory_processes.include?(comment.feature.participatory_process)
          end
          can :unreport, Comment
          can :hide, Comment
        end

        private

        def participatory_processes
          @participatory_processes ||= Decidim::Admin::ManageableParticipatoryProcessesForUser.for(@user)
        end
      end
    end
  end
end
