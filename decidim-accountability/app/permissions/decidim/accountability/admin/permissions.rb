# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?

          return false if permission_action.scope != :admin

          return true if can_perform_actions_on?(:result, result)
          return true if can_perform_actions_on?(:status, status)
          return true if can_perform_actions_on?(:timeline_entry, timeline_entry)

          false
        end

        private

        def result
          @result ||= context.fetch(:result, nil)
        end

        def status
          @status ||= context.fetch(:status, nil)
        end

        def timeline_entry
          @timeline_entry ||= context.fetch(:timeline_entry, nil)
        end

        def can_perform_actions_on?(subject, resource)
          return unless permission_action.subject == subject

          case permission_action.action
          when :create
            true
          when :update, :destroy
            resource.present?
          else
            false
          end
        end
      end
    end
  end
end
