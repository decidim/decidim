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

      ReplacementContext = Struct.new(:placement, :node_name, :attribute_name, :ancestor_names, keyword_init: true) do
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
        attr_modified = replace_pattern_in_attributes(fragment, pattern, skip_ancestor_tags:, on_missing:) do |match, context|
          yield(match, context)
        end
        text_modified = replace_pattern_in_text_nodes(fragment, pattern, skip_ancestor_tags:, on_missing:) do |match, context|
          yield(match, context)
        end

        return text unless attr_modified || text_modified

        fragment.to_s
      end

      private

      def replace_pattern_in_attributes(fragment, pattern, skip_ancestor_tags:, on_missing:)
        modified = false
        fragment.xpath(".//*").each do |node|
          next if skip_replacement_for_node?(node, skip_ancestor_tags)

          node.attribute_nodes.each do |attribute|
            replaced_value = attribute.value.gsub(pattern) do |match|
              replace_match(match, replacement_context(node, placement: :attribute, attribute_name: attribute.name), on_missing:) do |resolved_match, context|
                yield(resolved_match, context)
              end
            end
            unless replaced_value == attribute.value
              attribute.value = replaced_value
              modified = true
            end
          end
        end
        modified
      end

      def replace_pattern_in_text_nodes(fragment, pattern, skip_ancestor_tags:, on_missing:)
        modified = false
        fragment.xpath(".//text()").each do |node|
          parent = node.parent
          next if skip_replacement_for_node?(parent, skip_ancestor_tags)

          original_text = node.text
          has_node_match = pattern.is_a?(String) ? original_text.include?(pattern) : pattern.match?(original_text)
          next unless has_node_match

          doc = node.document
          context = replacement_context(parent, placement: :text)
          last_pos = 0

          original_text.scan(pattern) do
            m = Regexp.last_match
            node.add_previous_sibling(Nokogiri::XML::Text.new(original_text[last_pos...m.begin(0)], doc)) if m.begin(0) > last_pos

            replacement = replace_match(m[0], context, on_missing:) do |resolved_match, ctx|
              yield(resolved_match, ctx)
            end

            Loofah.fragment(replacement.to_s).children.to_a.each do |child|
              node.add_previous_sibling(child)
            end

            last_pos = m.end(0)
          end

          node.add_previous_sibling(Nokogiri::XML::Text.new(original_text[last_pos..], doc)) if last_pos < original_text.length
          node.remove
          modified = true
        end
        modified
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
