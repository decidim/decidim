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
      # and end with a terminal query method (`find`, `find_by`, `first`,
      # `take`, `exists?`, `find_or_create_by`, `destroy_all`, etc.) unless the
      # chain includes a recognized scoping step.
      class OrganizationScopedFinder < RuboCop::Cop::Base
        MSG = "Unscoped ActiveRecord finder detected. Scope the query to the current organization, " \
              "e.g. `current_organization.<relation>.find_by(id: params[:id])` or use an already-scoped `collection`."

        # Terminal methods that execute a database query. This is the subset of
        # `ActiveRecord::Querying::QUERYING_METHODS` that loads, creates,
        # mutates, or deletes records, so an unscoped call can cross
        # organization boundaries. Relation-building methods (`order`, `joins`,
        # etc.) are not listed here because they do not run the query by
        # themselves.
        FINDER_METHODS = [
          :find, :find_by, :find_by!, :find_sole_by, :first, :first!, :last, :last!,
          :sole, :sole!, :take, :take!,
          :second, :second!, :third, :third!, :fourth, :fourth!, :fifth, :fifth!,
          :forty_two, :forty_two!, :third_to_last, :third_to_last!, :second_to_last, :second_to_last!,
          :exists?, :any?, :many?, :none?, :one?
        ].freeze

        CREATION_FINDER_METHODS = [
          :first_or_create, :first_or_create!, :first_or_initialize,
          :find_or_create_by, :find_or_create_by!, :find_or_initialize_by,
          :create_or_find_by, :create_or_find_by!
        ].freeze

        MUTATION_METHODS = [
          :destroy, :destroy_all, :delete, :delete_all, :update_all, :touch_all, :destroy_by, :delete_by
        ].freeze

        QUERY_METHODS = [*FINDER_METHODS, *CREATION_FINDER_METHODS, *MUTATION_METHODS].freeze
        RESTRICT_ON_SEND = [*QUERY_METHODS, :where, :or].freeze

        RECORD_LOADING_METHODS = [:load, :load_async].freeze

        SCOPE_ROOT_METHODS = [:current_organization, :collection].freeze

        SCOPED_CREATION_FINDER_METHODS = CREATION_FINDER_METHODS

        SCOPED_WHERE_KEYS = [:current_organization, :current_component].freeze

        ORGANIZATION_SCOPED_KEYS = [:decidim_organization_id, :organization_id].freeze

        SCOPED_ASSOCIATION_KEYS = [:component, :organization, :participatory_space].freeze

        SCOPED_HELPER_METHODS = [:current_organization, :current_component, :current_participatory_space].freeze

        # Query objects are commonly built from a positional argument, e.g.
        # `AssembliesWithUserRole.for(current_user)`. The current user is bound
        # to the current organization, so it also establishes the tenant scope.
        SCOPED_QUERY_ARGUMENT_METHODS = [*SCOPED_HELPER_METHODS, :current_user].freeze

        # Framework and standard library constants expose query-like methods
        # (`File.delete`, `Rails.cache.delete`, etc.) without being
        # ActiveRecord models. Namespaced entries are matched as prefixes; the
        # remaining ones are only ignored when they are the full constant name,
        # so `Decidim` is ignored but `Decidim::Proposal` is not.
        IGNORED_CONSTANT_PREFIXES = %w(
          ActionController ActionDispatch ActionMailer ActionView ActiveModel ActiveSupport
          ActiveRecord Arel Bundler Devise Doorkeeper Rack Rails
        ).freeze
        IGNORED_CONSTANTS = %w(
          CGI Date DateTime Decidim Dir ENV File I18n JSON OpenSSL Pathname Process
          SecureRandom Thread Time URI
        ).freeze

        # SCREAMING_SNAKE_CASE constants hold plain values (e.g.
        # `OPTIONS = [25, 50, 100]`), not ActiveRecord model classes, which
        # follow the CamelCase convention.
        VALUE_CONSTANT_PATTERN = /\A[A-Z][A-Z0-9_]*\z/

        def on_send(node)
          return unless relevant_node?(node)
          return unless node.receiver

          # Check `or` relations before the model-constant gate: either branch
          # may be an unscoped relation whose receiver is not a model constant
          # (for example a delegated `taxonomies` relation).
          return check_or_relation(node) if node.method_name == :or

          return if organization_scoped?(node.receiver)
          return unless unscoped_model_class?(node.receiver) || unscoped_or_relation?(node.receiver)
          return if constructed_scope_root?(node.receiver)
          return if consumed_by_outer_relation?(node)

          add_offense(node)
        end

        private

        def relevant_node?(node)
          RESTRICT_ON_SEND.include?(node.method_name) && !node.block_node && !scoped_finder_arguments?(node)
        end

        def check_or_relation(node)
          return if node.ancestors.any? { |ancestor| ancestor.send_type? && ancestor.method_name == :or }
          return if scoped_or_branches?(node)
          return if consumed_by_outer_relation?(node)

          add_offense(node)
        end

        def organization_scoped?(node)
          return false unless node
          return true if scoped_node?(node)
          return false unless node.send_type?
          return scoped_or_branches?(node) if node.method_name == :or

          organization_scoped?(node.receiver)
        end

        def unscoped_model_class?(node)
          return false unless node
          return false if ignored_constant?(node)
          return true if node.const_type?
          return false unless node.send_type?

          unscoped_model_class?(node.receiver)
        end

        # An `or` relation whose branches are not all scoped can leak records
        # from another organization even when its receiver chain has no model
        # constant, as in `current_organization.taxonomies.or(Taxonomy.all)`.
        # Walk the whole receiver chain so intermediate calls between the `or`
        # and the terminal finder (e.g. `.order(:id)`) do not hide it.
        # `organization_scoped?` has already rejected the chain at this point.
        def unscoped_or_relation?(node)
          return false unless node&.send_type?
          return !scoped_or_branches?(node) if node.method_name == :or

          unscoped_or_relation?(node.receiver)
        end

        def ignored_constant?(node)
          return false unless node.const_type?

          IGNORED_CONSTANT_PREFIXES.any? { |prefix| node.source.start_with?(prefix) } ||
            IGNORED_CONSTANTS.include?(node.source) ||
            value_constant?(node)
        end

        def value_constant?(node)
          VALUE_CONSTANT_PATTERN.match?(node.short_name.to_s)
        end

        def scoped_node?(node)
          return false unless node.send_type?

          scope_root?(node) || scoped_where?(node) || scoped_finder_arguments?(node)
        end

        def scope_root?(node)
          return false unless SCOPE_ROOT_METHODS.include?(node.method_name)

          node.receiver.nil? || node.receiver.self_type?
        end

        # Also recognizes helpers that filter by a scoped association, such as
        # `MeetingLink.find_meetings(component: current_component)`.
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
            (value.hash_type? && value.children.any? { |inner| ownership_scoped_pair?(inner) })
        end

        def ownership_scoped_pair?(pair_node)
          return false unless pair_node.pair_type?

          key = pair_node.children[0]
          value = pair_node.children[1]

          scoped_association_pair?(key, value) ||
            (value.hash_type? && value.children.any? { |inner| ownership_scoped_pair?(inner) })
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
          return false unless value.method_name == :"current_#{key.value}"
          return true unless value.receiver

          # Accept form-provided context helpers such as
          # `form.current_component` or `@form.current_organization`, but not
          # arbitrary receivers that merely expose a similarly named method.
          form_context_receiver?(value.receiver)
        end

        def form_context_receiver?(node)
          return node.method_name == :form if node.send_type? && node.receiver.nil?
          return node.name == :form if node.lvar_type?

          node.ivar_type? && node.name == :@form
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

          if node.receiver&.const_type?
            return true if node.arguments.any? { |arg| scoped_constructor_argument?(arg) }

            return scoped_finder_arguments?(node)
          end

          return scoped_constructor_argument?(node) if node.method_name == :or

          constructed_scope_root?(node.receiver) if node.receiver
        end

        # Query objects in Decidim commonly receive the organization or the
        # current user as a positional argument, e.g.
        # `OrganizationAssemblies.new(current_organization)` or
        # `AssembliesWithUserRole.for(current_user)`.
        # For `or` relations, every branch must either already be
        # organization-scoped or be constructed from an organization-scoped
        # query object.
        def scoped_constructor_argument?(node)
          return scoped_query_argument_method?(node) unless node.send_type? && node.method_name == :or

          scoped_or_branches?(node)
        end

        def scoped_query_argument_method?(node)
          return false unless node.send_type?
          return false if node.receiver

          SCOPED_QUERY_ARGUMENT_METHODS.include?(node.method_name)
        end

        # An `or` relation is only safe when every nested branch is scoped,
        # not just the receiver of the `or` call.
        def scoped_or_branches?(node)
          return false unless node.receiver

          ([node.receiver] + node.arguments).all? do |branch|
            organization_scoped?(branch) || constructed_scope_root?(branch)
          end
        end

        # Report only the outermost relevant call of a receiver chain, so a
        # single query cannot produce several offenses.
        def consumed_by_outer_relation?(node)
          loads_records = loads_records?(node)
          ancestor = node.parent
          while ancestor&.send_type?
            break unless ancestor.receiver == node
            return true if reportable_outer_relation?(ancestor, loads_records)

            loads_records ||= loads_records?(ancestor)
            node = ancestor
            ancestor = node.parent
          end

          false
        end

        # A call with a block is usually an Enumerable operation rather than a
        # relation continuation, so the cop skips it and it cannot report the
        # offense for the query it receives. Scoped creation finders are the
        # exception: ActiveRecord applies their finder attributes before
        # loading records, and their block only initializes values on a new
        # record.
        #
        # Other calls that already scope their own arguments are also skipped
        # by `relevant_node?`, so they cannot report the offense for an inner
        # unscoped finder. Let that inner call remain reportable instead.
        #
        # A scoped call must not hide a lookup that already loaded records
        # before it ran. It can only consume inner calls that build the query.
        def reportable_outer_relation?(node, loads_records)
          return false unless RESTRICT_ON_SEND.include?(node.method_name)
          return false if node.block_node && !scoped_creation_finder?(node)
          return true unless scoped_finder_arguments?(node)
          return false if loads_records

          true
        end

        def loads_records?(node)
          QUERY_METHODS.include?(node.method_name) || RECORD_LOADING_METHODS.include?(node.method_name)
        end

        def scoped_creation_finder?(node)
          SCOPED_CREATION_FINDER_METHODS.include?(node.method_name) && scoped_finder_arguments?(node)
        end
      end
    end
  end
end
