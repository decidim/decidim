# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # Abstract base class for content renderers, so they have the same contract
    #
    # @example How to use a content renderer class
    #   renderer = Decidim::ContentRenderers::CustomRenderer.new(content)
    #   parser.render # returns the content formatted
    #
    # @abstract Subclass and override {#render} to implement a content renderer
    class BaseRenderer
      include Decidim::ContentProcessor::Common

      ReplacementContext = Struct.new(:placement, :node_name, :attribute_name, :ancestor_names, keyword_init: true) do # rubocop:disable Style/RedundantStructKeywordInit
        def text?
          placement == :text
        end

        def attribute?
          placement == :attribute
        end
      end

      # @return [String] the content to be formatted
      attr_reader :content

      # Gets initialized with the `content` to format
      #
      # @param content [String] content to be formatted
      def initialize(content)
        @content = content || ""
      end

      # Format the content and return it ready to display
      #
      # @example Implementation to display prohibited words
      #   def render
      #     content.gsub(/\~\~(.*?)\~\~/, '<del>\1</del>')
      #   end
      #
      # @abstract Subclass is expected to implement it
      # @return [String] the content processed and ready to display
      def render(_options = nil)
        content
      end

      protected

      def replace_pattern_by_context(text, pattern, skip_ancestor_tags: %w(code pre script style), on_missing: "")
        return text unless text.respond_to?(:gsub)
        skip_ancestor_tags = Array(skip_ancestor_tags).map(&:to_s)

        has_match = pattern.is_a?(String) ? text.include?(pattern) : pattern.match?(text)
        return text unless has_match

        fragment = html_fragment(text)
        replace_pattern_in_attributes(fragment, pattern, skip_ancestor_tags:, on_missing:) do |match, context|
          yield(match, context)
        end
        replace_pattern_in_text_nodes(fragment, pattern, skip_ancestor_tags:, on_missing:) do |match, context|
          yield(match, context)
        end

        fragment.to_s
      end

      private

      def replace_pattern_in_attributes(fragment, pattern, skip_ancestor_tags:, on_missing:)
        fragment.xpath(".//*").each do |node|
          next if skip_replacement_for_node?(node, skip_ancestor_tags)

          node.attribute_nodes.each do |attribute|
            replaced_value = attribute.value.gsub(pattern) do |match|
              replace_match(match, replacement_context(node, placement: :attribute, attribute_name: attribute.name), on_missing:) do |resolved_match, context|
                yield(resolved_match, context)
              end
            end
            attribute.value = replaced_value unless replaced_value == attribute.value
          end
        end
      end

      def replace_pattern_in_text_nodes(fragment, pattern, skip_ancestor_tags:, on_missing:)
        fragment.xpath(".//text()").each do |node|
          parent = node.parent
          next if skip_replacement_for_node?(parent, skip_ancestor_tags)

          replaced_text = node.text.gsub(pattern) do |match|
            replace_match(match, replacement_context(parent, placement: :text), on_missing:) do |resolved_match, context|
              yield(resolved_match, context)
            end
          end
          next if replaced_text == node.text

          node.replace(replaced_text)
        end
      end

      def replace_match(match, context, on_missing:)
        yield(match, context)
      rescue ActiveRecord::RecordNotFound
        on_missing.respond_to?(:call) ? on_missing.call(match, context) : on_missing
      end

      def replacement_context(node, placement:, attribute_name: nil)
        ReplacementContext.new(
          placement:,
          node_name: node&.name,
          attribute_name:,
          ancestor_names: node ? node.ancestors.map(&:name) : []
        )
      end

      def skip_replacement_for_node?(node, skip_ancestor_tags)
        return false unless node

        ([node.name] + node.ancestors.map(&:name)).any? { |name| skip_ancestor_tags.include?(name) }
      end
    end
  end
end
