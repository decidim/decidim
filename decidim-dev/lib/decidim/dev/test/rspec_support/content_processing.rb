# frozen_string_literal: true

module Decidim
  class ContentParsers::DummyFooParser < ContentParsers::BaseParser
    def rewrite
      content.gsub("foo", "%lorem%")
    end

    def metadata
      content.scan("foo").size
    end
  end

  class ContentRenderers::DummyFooRenderer < ContentRenderers::BaseRenderer
    def render(_options = nil)
      content.gsub("%lorem%", "<em>neque dicta enim quasi</em>")
    end
  end

  class ContentParsers::DummyBarParser < ContentParsers::BaseParser
    def rewrite
      content.gsub("bar", "*ipsum*")
    end

    def metadata
      content.scan("bar").size
    end
  end

  class ContentRenderers::DummyBarRenderer < ContentRenderers::BaseRenderer
    def render(_options = nil)
      content.gsub("*ipsum*", "<em>illo qui voluptas</em>")
    end
  end
end
