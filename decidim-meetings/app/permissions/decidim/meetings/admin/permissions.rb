# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions
        def initialize(user, permission_action, context)
          @user = user
          @permission_action = permission_action
          @context = context
        end

        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?
          return false unless user

          return false if permission_action.scope != :admin

          return false if permission_action.subject != :meeting

          return true if case permission_action.action
                         when :close, :copy, :destroy, :update
                           meeting.present?
                         when :create
                           true
                         else
                           false
                         end

          false
        end

        private

        attr_reader :user, :permission_action, :context

        def spaces_allows_user?
          return unless space.manifest.permissions_class
          space.manifest.permissions_class.new(user, permission_action, context).allowed?
        end

        def current_settings
          @current_settings ||= context.fetch(:current_settings, nil)
        end

        def component_settings
          @component_settings ||= context.fetch(:component_settings, nil)
        end

        def component
          @component ||= context.fetch(:current_component)
        end

        def space
          @space ||= component.participatory_space
        end

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end
      end
    end
  end
end
