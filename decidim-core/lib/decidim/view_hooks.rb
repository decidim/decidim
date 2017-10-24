# frozen_string_literal: true

module Decidim
  class ViewHooks
    HIGH_PRIORITY = 1
    MEDIUM_PRIORITY = 2
    LOW_PRIORITY = 3

    def initialize(hooks = Hash.new { |h, k| h[k] = [] })
      @hooks = hooks
    end

    # Public: Register a view for a given view hook
    #
    # name - The name of the view hook
    # options - A hash of options
    #         * priority: The priority of the stat used for render issues.
    #         * partial: The name of the partial that needs to be rendered.
    #
    # Returns nothing.
    def register(name, options = {})
      raise StandardError, "Option `:partial` is not defined" if options[:partial].blank?
      options[:priority] ||= LOW_PRIORITY

      hooks[name].push(options)
    end

    # Gets all the view hooks registered for a given hook name.
    #
    # name - The name of the view hook
    #
    # Returns an array of Hashes.
    def get(name)
      hooks[name]
    end

    private

    attr_reader :hooks
  end
end
