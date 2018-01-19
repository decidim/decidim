# frozen_string_literal: true

module Decidim
  class ContentParsers::DummyFooParser < ContentParsers::BaseParser
    def rewrite
      content.gsub("foo", "_foo_")
    end

    def metadata
      content.scan("foo").size
    end
  end

  class ContentRenderers::DummyFooRenderer < ContentRenderers::BaseRenderer
    def render
      content.gsub("_foo_", "foo")
    end
  end

  class ContentParsers::DummyBarParser < ContentParsers::BaseParser
    def rewrite
      content.gsub("bar", "_bar_")
    end

    def metadata
      content.scan("bar").size
    end
  end

  class ContentRenderers::DummyBarRenderer < ContentRenderers::BaseRenderer
    def render
      content.gsub("_bar_", "bar")
    end
  end
end
