# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      # Flags unscoped ActiveRecord finder calls in controllers.
      #
      # In a multi-tenant Decidim deployment, loading a record without scoping
      # it to the current organization can allow one tenant's users to access
      # another tenant's resources. This cop promotes safe patterns such as
      # `current_organization.templates.find_by(id: ...)` or using an already
      # scoped `collection`.
      #
      # The cop targets chains that start with an ActiveRecord model constant
      # and end with a terminal finder (`find`, `find_by`, `find_by!`, `first`,
      # `take`, etc.) unless the chain includes a recognized scoping step.
      class OrganizationScopedFinder < RuboCop::Cop::Base
        MSG = "Unscoped ActiveRecord finder detected. Scope the query to the current organization, " \
              "e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`."

        FINDER_METHODS = [:find, :find_by, :find_by!, :first, :first!, :take, :take!].freeze
        RESTRICT_ON_SEND = [*FINDER_METHODS, :where].freeze

        SCOPE_ROOT_METHODS = [:current_organization, :collection].freeze

        SCOPED_WHERE_KEYS = [:current_organization, :current_component].freeze

        ORGANIZATION_SCOPED_KEYS = [:decidim_organization_id, :organization_id].freeze

        SCOPED_ASSOCIATION_KEYS = [:component, :organization, :participatory_space].freeze

        SCOPED_HELPER_METHODS = [:current_organization, :current_component, :current_participatory_space].freeze

        IGNORED_CONSTANT_PREFIXES = %w(Bundler ActiveRecord).freeze

        def on_send(node)
          return unless RESTRICT_ON_SEND.include?(node.method_name)
          return if node.block_node
          return if scoped_finder_arguments?(node)
          return unless node.receiver
          return if organization_scoped?(node.receiver)
          return unless unscoped_model_class?(node.receiver)
          return if constructed_scope_root?(node.receiver)

          return if consumed_by_finder?(node)

          add_offense(node)
        end

        private

        def organization_scoped?(node)
          return false unless node
          return true if scoped_node?(node)
          return organization_scoped?(node.receiver) if node.send_type?

          false
        end

        def unscoped_model_class?(node)
          return false unless node
          return false if ignored_constant?(node)
          return true if node.const_type?
          return false unless node.send_type?

          unscoped_model_class?(node.receiver)
        end

        def ignored_constant?(node)
          node.const_type? &&
            IGNORED_CONSTANT_PREFIXES.any? { |prefix| node.source.start_with?(prefix) }
        end

        def scoped_node?(node)
          return false unless node.send_type?

          scope_root?(node) || scoped_where?(node)
        end

        def scope_root?(node)
          return false unless SCOPE_ROOT_METHODS.include?(node.method_name)

          node.receiver.nil? || node.receiver.self_type?
        end

        def scoped_finder_arguments?(node)
          node.arguments.any? { |arg| scoped_argument?(arg) }
        end

        def scoped_where?(node)
          return false unless node.method_name == :where

          node.arguments.any? { |arg| scoped_argument?(arg) }
        end

        def scoped_argument?(node)
          return false unless node.hash_type?

          node.children.any? { |pair| scoped_pair?(pair) }
        end

        def scoped_pair?(pair_node)
          return false unless pair_node.pair_type?

          key = pair_node.children[0]
          value = pair_node.children[1]

          scoped_where_pair?(key, value) ||
            scoped_association_pair?(key, value) ||
            (value.hash_type? && value.children.any? { |inner| scoped_pair?(inner) })
        end

        def scoped_where_pair?(key, value)
          return false unless key.sym_type?
          return false unless scoped_where_key?(key)

          scoped_trusted_value?(value)
        end

        def scoped_association_pair?(key, value)
          return false unless key.sym_type?
          return false unless SCOPED_ASSOCIATION_KEYS.include?(key.value)
          return false unless value.send_type?
          return false if value.receiver

          value.method_name == :"current_#{key.value}"
        end

        def scoped_trusted_value?(node)
          return false unless node

          case node.type
          when :send
            scoped_helper_method?(node) || (node.receiver && scoped_trusted_value?(node.receiver))
          when :hash
            node.children.any? { |pair| scoped_pair?(pair) }
          else
            false
          end
        end

        def scoped_helper_method?(node)
          return false unless node.send_type?
          return false if node.receiver

          SCOPED_HELPER_METHODS.include?(node.method_name)
        end

        def scoped_where_key?(key)
          key.sym_type? &&
            (SCOPED_WHERE_KEYS.include?(key.value) ||
             ORGANIZATION_SCOPED_KEYS.include?(key.value))
        end

        def constructed_scope_root?(node)
          return false unless node.send_type?

          if node.method_name == :new
            return false unless node.receiver&.const_type?

            return scoped_finder_arguments?(node)
          end

          constructed_scope_root?(node.receiver) if node.receiver
        end

        def consumed_by_finder?(node)
          return false unless node.method_name == :where

          ancestor = node.parent
          while ancestor&.send_type?
            break unless ancestor.receiver == node
            return true if FINDER_METHODS.include?(ancestor.method_name)

            node = ancestor
            ancestor = node.parent
          end

          false
        end
      end
    end
  end
end
