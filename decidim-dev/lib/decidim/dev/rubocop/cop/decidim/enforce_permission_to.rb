# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      # Flags controller actions that lack authorization checks.
      #
      # In Decidim admin controllers, every action must explicitly call
      # `enforce_permission_to` or `action_authorized_to` to verify the
      # current user has permission to perform that action. Missing
      # authorization checks can allow unauthorized access to resources.
      #
      # This cop checks all public method definitions in admin controllers
      # and flags any that don't contain an authorization call.
      #
      # Actions are exempt when the controller uses a `before_action` that
      # performs authorization (either by referencing a method that calls
      # `enforce_permission_to`, or by using a name containing
      # "permission", "authorize", or "enforce").
      #
      # @example
      #   # bad
      #   class Admin::ResourcesController < Admin::ApplicationController
      #     def edit
      #       @resource = Resource.find(params[:id])
      #     end
      #   end
      #
      #   # good
      #   class Admin::ResourcesController < Admin::ApplicationController
      #     def edit
      #       enforce_permission_to :update, :resource, resource:
      #       @resource = Resource.find(params[:id])
      #     end
      #   end
      #
      #   # good - authorization via before_action
      #   class Admin::ResourcesController < Admin::ApplicationController
      #     before_action :ensure_permissions
      #
      #     def edit
      #       @resource = Resource.find(params[:id])
      #     end
      #
      #     private
      #
      #     def ensure_permissions
      #       enforce_permission_to :update, :resource
      #     end
      #   end
      class EnforcePermissionTo < RuboCop::Cop::Base
        MSG = "Action `%<action>s` is missing an authorization check. " \
              "Add `enforce_permission_to` or `action_authorized_to` at the start of the action, " \
              "or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere."

        AUTHORIZATION_METHODS = [:enforce_permission_to, :action_authorized_to].freeze

        BEFORE_ACTION_AUTH_KEYWORDS = %w(permission authorize enforce).freeze

        def on_class(node)
          reset_state
          check_helper_methods(node)
          check_before_actions(node)
          check_before_action_blocks(node)
        end

        def on_module(node)
          reset_state
          check_helper_methods(node)
          check_before_actions(node)
          check_before_action_blocks(node)
        end

        def on_def(node)
          method_name = node.method_name
          @defined_methods ||= {}
          @defined_methods[method_name] = node

          return if @in_private_section
          return if @before_action_auth
          return if @helper_methods.include?(method_name)

          action_name = method_name.to_s
          return unless action_name?(action_name)

          return if contains_authorization_check?(node)

          add_offense(node, message: format(MSG, action: action_name))
        end

        def on_send(node)
          return unless node.method_name == :private || node.method_name == :protected
          return unless node.arguments.empty?

          @in_private_section = true
        end

        private

        def reset_state
          @in_private_section = false
          @before_action_auth = false
          @defined_methods = {}
          @helper_methods = Set.new
        end

        def check_helper_methods(node)
          node.body&.each_descendant(:send) do |send_node|
            next unless send_node.method_name == :helper_method

            send_node.arguments.each do |arg|
              @helper_methods << arg.value if arg.sym_type?
            end
          end
        end

        def check_before_actions(class_node)
          class_node.body&.each_child_node(:send) do |send_node|
            next unless send_node.method_name == :before_action

            if before_action_handles_auth?(send_node)
              @before_action_auth = true
              break
            end
          end
        end

        def check_before_action_blocks(class_node)
          class_node.body&.each_descendant(:block) do |block_node|
            next unless block_node.send_node.method_name == :before_action

            if block_contains_auth?(block_node)
              @before_action_auth = true
              break
            end
          end
        end

        def before_action_handles_auth?(node)
          node.arguments.any? do |arg|
            auth_symbol_argument?(arg)
          end
        end

        def block_contains_auth?(block_node)
          body = block_node.body
          return false unless body

          return true if authorization_call?(body)

          body.each_descendant(:send).any? do |send_node|
            authorization_call?(send_node)
          end
        end

        def auth_symbol_argument?(arg)
          return false unless arg.sym_type?

          name = arg.value.to_s
          BEFORE_ACTION_AUTH_KEYWORDS.any? { |keyword| name.include?(keyword) }
        end

        def action_name?(name)
          %w(index show new edit create update destroy).include?(name)
        end

        def contains_authorization_check?(node)
          return false unless node.body

          body = node.body

          return true if authorization_call?(body)

          body.each_descendant(:send).any? do |send_node|
            authorization_call?(send_node)
          end
        end

        def authorization_call?(send_node)
          return false unless send_node.send_type?

          return true if AUTHORIZATION_METHODS.include?(send_node.method_name)

          method_name = send_node.method_name.to_s
          BEFORE_ACTION_AUTH_KEYWORDS.any? { |keyword| method_name.include?(keyword) }
        end
      end
    end
  end
end
