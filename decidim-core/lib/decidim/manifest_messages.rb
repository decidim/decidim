# frozen_string_literal: true

module Decidim
  class ManifestMessages
    def initialize
      @store = {}
    end

    def has?(key)
      @store.has_key?(key)
    end

    def set(key, &block)
      raise ArgumentError, "You need to provide a block for the message." unless block_given?

      @store[key] = block
    end

    def render(key, context = nil, **)
      context.instance_exec(**, &@store[key]) if @store[key]
    end
  end
end
