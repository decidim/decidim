# frozen_string_literal: true

module Decidim
  # This class acts as a registry for view hooks. It saves paths to partials found in
  # engines so they can be included in other engines. Each engine can have its own
  # instance of this class, so that view hooks are namespaced instead of global.
  #
  # This mechanism is useful to extend the views of a given engine from other engines.
  # For example, the homepage of Decidim is found on `decidim-core`, but it can be
  # extended by other engine to show important info there. For example, an engine might
  # want to extend the homepage to show highlighted participatory processes.
  #
  # In order to show view hooks, you can use something like this in your views:
  #
  #     Decidim.view_hooks # => an instance of this class
  #     <% Decidim.view_hooks.get(:my_hook).each do |hook| %>
  #       <%= render partial: hook[:partial]
  #     <% end %>
  #
  # In order to add more partials to this view hook, you can register as in the
  # following example. Note that you will probably use this from your engine initializer.
  #
  #     Decidim.view_hooks.register(
  #       :my_hook,
  #       priority: Decidim::ViewHooks::HIGH_PRIORITY,
  #       partial: "path/to/my/partial"
  #     )
  class ViewHooks
    HIGH_PRIORITY = 1
    MEDIUM_PRIORITY = 2
    LOW_PRIORITY = 3

    # Initializes the class.
    #
    # hooks - a Hash to store the different view hooks. By default, it's a Hash with
    #   Arrays as default values.
    def initialize(hooks = Hash.new { |h, k| h[k] = [] })
      @hooks = hooks
    end

    # Public: Register a view partial for a given view hook. It automatically sorts the
    # partials for a given hook name by priority.
    #
    # name - a symbol representing the name of the view hook
    # options - A hash of options
    #         * priority: The priority of the partial to be rendered. Default is `LOW_PRIORITY`
    #         * partial: The name of the partial that needs to be rendered.
    #
    # Returns nothing.
    def register(name, options = {})
      raise StandardError, "Option `:partial` is not defined" if options[:partial].blank?
      options[:priority] ||= LOW_PRIORITY

      hooks[name].push(options)
      hooks[name].sort_by! { |hook| hook[:priority] }
    end

    # Gets all the view hooks registered for a given hook name.
    #
    # name - The name of the view hook
    #
    # Returns an array of Hashes, ordered by their `:priority` key value.
    def get(name)
      hooks[name]
    end

    private

    attr_reader :hooks
  end
end
