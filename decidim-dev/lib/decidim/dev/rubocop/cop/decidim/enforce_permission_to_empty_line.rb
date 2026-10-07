# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      # Enforces an empty line after every `enforce_permission_to` call.
      #
      # Placing the permission check apart from the rest of the action body
      # makes it easier to spot, as it is the first thing an action should do.
      # When `enforce_permission_to` is the only (or the last) statement of a
      # method, there is no following code to separate it from, so no empty
      # line is required.
      #
      # @example
      #   # bad
      #   def edit
      #     enforce_permission_to :update, :resource
      #     @resource = Resource.find(params[:id])
      #   end
      #
      #   # good
      #   def edit
      #     enforce_permission_to :update, :resource
      #
      #     @resource = Resource.find(params[:id])
      #   end
      #
      #   # good - single statement action
      #   def edit
      #     enforce_permission_to :update, :resource
      #   end
      class EnforcePermissionToEmptyLine < RuboCop::Cop::Base
        include RangeHelp
        extend AutoCorrector

        MSG = "Add an empty line after `enforce_permission_to`."

        RESTRICT_ON_SEND = [:enforce_permission_to].freeze

        def on_send(node)
          return if no_following_statement?(node)
          return if next_line_empty?(node)

          add_offense(node, message: MSG) do |corrector|
            corrector.insert_after(correction_range(node), "\n")
          end
        end

        private

        # Returns true when the call is the last statement of the enclosing
        # body, so there is nothing to separate the permission check from.
        def no_following_statement?(node)
          parent = node.parent
          return true unless parent&.begin_type? || parent&.kwbegin_type?

          parent.children.last == node
        end

        def next_line_empty?(node)
          processed_source.lines[end_line(node)].to_s.strip.empty?
        end

        # The line where the call visually ends.
        #
        # A trailing hash written with value omission (e.g. `page:`) followed
        # by another line makes the parser treat that line as the omitted
        # value, extending the node past the line the developer wrote. In that
        # case the call visually ends at the omitted key.
        def end_line(node)
          pair = trailing_shorthand_pair(node)
          return node.last_line unless pair

          pair.key.last_line
        end

        def correction_range(node)
          pair = trailing_shorthand_pair(node)
          return range_by_whole_lines(node.source_range) unless pair

          range_by_whole_lines(pair.key.source_range)
        end

        def trailing_shorthand_pair(node)
          hash = node.arguments.last
          return unless hash&.hash_type?

          pair = hash.pairs.last
          return unless pair

          key = pair.key
          value = pair.value
          return unless key && value && value.first_line > key.last_line

          pair
        end
      end
    end
  end
end
