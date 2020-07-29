# frozen_string_literal: true

require "decidim/map/provider/here"
require "decidim/map/provider/osm"

module Decidim
  # A utility for managing snippets that need to be registered during the view
  # display and displayed in another part of the application. For example, maps
  # can register their snippets when the map is displayed but they need to be
  # added to the <head> section of the document.
  class Snippets
    def initialize
      @snippets = {}
    end

    def add(category, *snippet)
      @snippets[category] ||= []
      @snippets[category].push(*snippet)
    end

    def for(category)
      @snippets[category]
    end

    def any?(category)
      self.for(category).present?
    end
  end
end
