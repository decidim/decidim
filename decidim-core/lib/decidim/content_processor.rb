# frozen_string_literal: true

module Decidim
  module ContentProcessor
    Result = Struct.new(:rewrite, :metadata)

    # This calls all registered parsers one after the other and return
    # a hash with the content rewrited and the merged metadata of all parsers
    # parsed = Decidim::ContentParsers.parse(content)
    # parsed.rewrite # contains rewritten content
    # parsed.metadata # contains the merged metadata of all parsers
    def self.parse(content)
      parsed = Decidim.content_processors.each_with_object(rewrite: content, metadata: {}) do |type, result|
        parser = parser_klass(type).constantize.new(result[:rewrite])
        result[:rewrite] = parser.rewrite
        result[:metadata][type] = parser.metadata
      end

      Result.new(parsed[:rewrite], parsed[:metadata])
    end

    def self.render(content)
      Decidim.content_processors.reduce(content) do |result, type|
        renderer_klass(type).constantize.new(result).render
      end
    end

    def self.parser_klass(type)
      "Decidim::ContentParsers::#{type.to_s.camelize}Parser"
    end

    def self.renderer_klass(type)
      "Decidim::ContentRenderers::#{type.to_s.camelize}Renderer"
    end
  end
end
