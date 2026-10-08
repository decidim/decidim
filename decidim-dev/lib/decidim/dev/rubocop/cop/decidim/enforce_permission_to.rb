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
      # and flags any that do not contain an authorization call.
      #
      # Actions are exempt when the controller uses a `before_action` that
      # performs authorization (either by referencing a method that calls
      # `enforce_permission_to`, or by using a name containing
      # "permission", "authorize", or "enforce"). When such `before_action`
      # is restricted with `only:` or `except:`, only the actions it covers
      # are exempt.
      #
      # Methods referenced by framework lifecycle callbacks (`before_action`
      # and its variants, `around_action`, `after_action`, `helper_method`,
      # `rescue_from`, ...) are treated as lifecycle/helper methods and are
      # never flagged, as they themselves are not controller actions.
      #
      # Controllers that inherit from a configured `AuthorizedBaseClasses`
      # entry are considered to inherit the base authorization check for the
      # `AuthorizedBaseActions` actions (typically read-style actions such as
      # `index`, `show` and `home`). Mutating actions must still be
      # authorized explicitly.
      #
      # Calls to methods starting with `enforce_permission_to_` or
      # `action_authorized_to_` (authorization helper wrappers) are also
      # accepted as authorization checks.
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
        MSG = "Action `%{action}` is missing an authorization check. " \
              "Add `enforce_permission_to` or `action_authorized_to` at the start of the action, " \
              "or use `# rubocop:disable Decidim/EnforcePermissionTo` if authorization is handled elsewhere."

        AUTHORIZATION_METHODS = [:enforce_permission_to, :action_authorized_to].freeze

        # Prefixes accepted for authorization helper wrappers, such as
        # `enforce_permission_to_update_resource`.
        AUTHORIZATION_PREFIXES = %w(enforce_permission_to_ action_authorized_to_).freeze

        BEFORE_ACTION_AUTH_KEYWORDS = %w(permission authorize enforce).freeze

        # Visibility switch methods recognized when declared with no arguments.
        VISIBILITY_METHODS = [:public, :protected, :private].freeze

        # Framework declarations whose referenced methods are lifecycle or
        # helper methods rather than controller actions.
        CALLBACK_METHODS = [
          :before_action, :prepend_before_action, :append_before_action, :skip_before_action,
          :around_action, :prepend_around_action, :append_around_action, :skip_around_action,
          :after_action, :prepend_after_action, :append_after_action, :skip_after_action,
          :helper_method, :rescue_from
        ].freeze

        def on_new_investigation
          @callback_methods = Set.new
          @base_class_map = {}
          reset_scope_state
        end

        def on_class(node)
          reset_scope_state
          register_authorized_base(node)
          collect_callback_methods(node)
          check_before_actions(node)
          check_before_action_blocks(node)
        end

        def on_module(node)
          reset_scope_state
          collect_callback_methods(node)
          check_before_actions(node)
          check_before_action_blocks(node)
        end

        def on_def(node)
          method_name = node.method_name

          inline_visibility = @inline_visibility
          @inline_visibility = nil

          return unless method_public?(node, method_name, inline_visibility)
          return if action_exempted_by_before_action?(method_name)
          return if @callback_methods.include?(method_name)
          return if authorized_base_action?(method_name)

          return if contains_authorization_check?(node)

          action_name = method_name.to_s
          add_offense(node, message: format(MSG, action: action_name))
        end

        def on_send(node)
          return unless VISIBILITY_METHODS.include?(node.method_name)

          if node.arguments.empty?
            @in_private_section = node.method_name != :public
          elsif visibility_def_argument?(node)
            # `private def foo` only makes that single method private, it does
            # not change the default visibility for the following methods.
            @inline_visibility = node.method_name
          end
        end

        private

        # Callback methods are accumulated for the whole file so that methods
        # defined in nested modules (a common concern pattern) are still
        # recognized as lifecycle/helper methods.
        def reset_scope_state
          @in_private_section = false
          @inline_visibility = nil
          @all_actions_auth = false
          @only_actions = Set.new
          @except_sets = []
          @authorized_base = false
        end

        def visibility_def_argument?(node)
          node.arguments.any?(&:def_type?)
        end

        def method_public?(node, method_name, inline_visibility)
          named_visibility = named_visibility_for(node, method_name)
          return named_visibility == :public if named_visibility

          visibility = inline_visibility || (@in_private_section ? :private : :public)
          visibility == :public
        end

        # Resolves named visibility modifiers such as `public :publish` or
        # `private :resource` that appear after the method definition. In Ruby
        # these modifiers only apply to methods already defined, so a modifier
        # placed before a later `def` does not change that definition's
        # visibility. Among the applicable modifiers, the last one wins.
        def named_visibility_for(node, method_name)
          scope = node.each_ancestor(:class, :module).first
          return nil unless scope

          named_visibility_overrides(scope, node)[method_name]
        end

        def named_visibility_overrides(scope, node)
          def_end = node.source_range.end_pos

          scope.body&.each_child_node&.with_object({}) do |child, overrides|
            next unless named_visibility_after?(child, def_end)

            child.arguments.each do |arg|
              covered_actions(arg).each do |name|
                overrides[name] = child.method_name
              end
            end
          end || {}
        end

        def named_visibility_after?(child, def_end)
          named_visibility_modifier?(child) && child.source_range.begin_pos > def_end
        end

        def named_visibility_modifier?(node)
          node.send_type? && VISIBILITY_METHODS.include?(node.method_name) &&
            !node.arguments.empty? && !visibility_def_argument?(node)
        end

        # Collects the methods that play a lifecycle or helper role for the
        # controller. These are referenced by framework callback declarations
        # (and the methods they call) so they are never reported as actions.
        def collect_callback_methods(node)
          return unless node.body

          definitions = callback_definitions(node)
          collect_callback_declarations(node)
          collect_callback_dependencies(definitions)
        end

        def collect_callback_declarations(node)
          node.body.each_descendant(:send) do |send_node|
            next unless CALLBACK_METHODS.include?(send_node.method_name)

            callback_method_names(send_node).each { |name| @callback_methods << name }
          end
        end

        def callback_definitions(node)
          node.body.each_descendant(:def).with_object({}) do |def_node, definitions|
            definitions[def_node.method_name] ||= def_node
          end
        end

        # Methods called by a lifecycle callback are helper methods as well,
        # e.g. a callback delegating to a public helper method.
        def collect_callback_dependencies(definitions)
          queue = @callback_methods.to_a

          until queue.empty?
            definition = definitions[queue.shift]
            next unless definition&.body

            sends = [definition.body]
            sends.concat(definition.body.each_descendant(:send).to_a)

            sends.each do |send_node|
              next unless send_node.send_type?
              next unless controller_call?(send_node)

              callee = send_node.method_name
              next unless definitions.has_key?(callee)
              next unless @callback_methods.add?(callee)

              queue << callee
            end
          end
        end

        # A call is made on the controller itself when the receiver is implicit
        # or an explicit `self`. Calls with any other receiver, such as
        # `Resource.find`, must not be followed because a same-named controller
        # action could then be mistaken for a lifecycle/helper method, hiding a
        # missing authorization check.
        def controller_call?(send_node)
          send_node.receiver.nil? || send_node.receiver.self_type?
        end

        def callback_method_names(send_node)
          send_node.arguments.flat_map do |arg|
            case arg.type
            when :sym, :str
              arg.value.to_sym
            when :hash
              rescue_handler_names(arg)
            else
              []
            end
          end
        end

        # `rescue_from SomeError, with: :handler` references the handler
        # method through the `with:` option.
        def rescue_handler_names(hash_node)
          hash_node.pairs.filter_map do |pair|
            next unless pair.key.sym_type? && pair.key.value == :with

            value = pair.value
            value.value.to_sym if value.sym_type? || value.str_type?
          end
        end

        def register_authorized_base(node)
          register_class_hierarchy(node)
          @authorized_base = authorized_base_class?(node)
        end

        # Keeps track of the class hierarchy so authorization inherited from a
        # configured base class can be recognized through intermediate classes.
        def register_class_hierarchy(node)
          name = qualified_class_name(node)
          return unless name

          parent = node.parent_class
          @base_class_map ||= {}
          @base_class_map[name] = parent.const_name if parent&.const_type?
        end

        def qualified_class_name(node)
          identifier = node.identifier
          return nil unless identifier&.const_type?

          namespace = node.each_ancestor(:class, :module).to_a.reverse.filter_map do |ancestor|
            ancestor.identifier&.const_name
          end

          (namespace + [identifier.const_name]).join("::")
        end

        def authorized_base_class?(node)
          parent = node.parent_class
          return false unless parent&.const_type?

          authorized_base_name?(parent.const_name)
        end

        def authorized_base_name?(name)
          seen = Set.new

          while name && seen.add?(name)
            return true if authorized_base_classes.include?(name)

            name = @base_class_map[name]
          end

          false
        end

        def authorized_base_classes
          @authorized_base_classes ||= Array(cop_config["AuthorizedBaseClasses"]).map(&:to_s)
        end

        def authorized_base_actions
          @authorized_base_actions ||= Array(cop_config["AuthorizedBaseActions"]).map(&:to_s)
        end

        def authorized_base_action?(method_name)
          @authorized_base && authorized_base_actions.include?(method_name.to_s)
        end

        def check_before_actions(class_node)
          class_node.body&.each_child_node(:send) do |send_node|
            next unless send_node.method_name == :before_action

            register_auth_before_action(send_node) if before_action_handles_auth?(send_node)
          end
        end

        def check_before_action_blocks(class_node)
          class_node.body&.each_descendant(:block) do |block_node|
            next unless block_node.send_node.method_name == :before_action

            register_auth_before_action(block_node.send_node) if block_contains_auth?(block_node)
          end
        end

        def before_action_handles_auth?(node)
          node.arguments.any? do |arg|
            auth_symbol_argument?(arg)
          end
        end

        def register_auth_before_action(node)
          only, except = action_restrictions(node)

          if only
            only -= except if except
            @only_actions.merge(only)
          elsif except
            @except_sets << except
          else
            @all_actions_auth = true
          end
        end

        def action_exempted_by_before_action?(method_name)
          return true if @all_actions_auth
          return true if @only_actions.include?(method_name)
          return true if @except_sets.any? { |actions| actions.none?(method_name) }

          false
        end

        def action_restrictions(node)
          only = nil
          except = nil

          node.arguments.each do |arg|
            next unless arg.hash_type?

            arg.pairs.each do |pair|
              next unless pair.key.sym_type?

              case pair.key.value
              when :only
                only = covered_actions(pair.value)
              when :except
                except = covered_actions(pair.value)
              end
            end
          end

          [only, except]
        end

        def covered_actions(value)
          nodes = value.array_type? ? value.children : [value]

          nodes.select { |node| node.sym_type? || node.str_type? }
               .to_set { |node| node.value.to_sym }
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
          AUTHORIZATION_PREFIXES.any? { |prefix| method_name.start_with?(prefix) }
        end
      end
    end
  end
end
