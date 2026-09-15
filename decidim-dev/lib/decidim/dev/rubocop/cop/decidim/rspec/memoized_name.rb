# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      module RSpec
        class MemoizedName < RuboCop::Cop::Base
          RESERVED_NAMES = {
            "ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper" => [
              :increment_unique,
              :unique,
              :image_name,
              :image_path,
              :html_path,
              :absolute_path,
              :screenshots_dir,
              :absolute_image_path,
              :relative_image_path,
              :absolute_html_path,
              :output_type
            ].freeze
          }.freeze

          MSG = "Do not use reserved names as memoized variable names in system specs: %s. Reserved by: %s."

          def on_send(node)
            return unless [:let, :let!].include?(node.method_name)
            return if within_block?(node)

            first_argument = node.first_argument
            return unless first_argument
            return unless first_argument.sym_type?

            RESERVED_NAMES.each do |klass, methods|
              next unless methods.include?(first_argument.value)

              add_offense(first_argument, message: format(MSG, first_argument.value, klass))
            end
          end

          private

          def within_block?(node)
            node.each_ancestor(:block).any? do |ancestor|
              ancestor.send_node&.method_name == :within
            end
          end
        end
      end
    end
  end
end
