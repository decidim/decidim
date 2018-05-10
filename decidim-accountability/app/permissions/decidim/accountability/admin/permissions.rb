# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          permission_action.allow! if can_perform_actions_on?(:result, result)
          permission_action.allow! if can_perform_actions_on?(:status, status)
          permission_action.allow! if can_perform_actions_on?(:timeline_entry, timeline_entry)

          permission_action
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
