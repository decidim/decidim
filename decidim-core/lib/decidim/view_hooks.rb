# frozen_string_literal: true

module Decidim
  # This class acts as a registry for view hooks. It saves paths to partials found in
  # engines so they can be included in other engines. Each engine can have its own
  # instance of this class, so that view hooks are namespaced instead of global.
  #
  # This mechanism is useful to extend the views of a given engine from other engines.
  # For example, the homepage of Decidim is found on `decidim-core`, but it can be
  # extended by other engines to show important info there. For example, an engine might
  # want to extend the homepage to show highlighted participatory processes.
  #
  # In order to show view hooks, you can use something like this in your views:
  #
  #     Decidim::MyModule.view_hooks # => an instance of this class
  #     <%= Decidim::MyModule.view_hooks.render(:my_hook, self) %>
  #
  # If you want to hide that call, you can wrap this in a helper method so you don't need
  # to call `self` from the views directly.
  #
  # In order to add more partials to this view hook, you can register as in the
  # following example. Note that you will probably use this from your engine initializer.
  #
  #     Decidim::MyModule.view_hooks.register(
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
    # priority - a Number (Integer|Float) to sort the block.
    # &block - The block that will be rendered in the view hook.
    #
    # Returns nothing.
    def register(name, priority: LOW_PRIORITY, &block)
      hooks[name].push(ViewHook.new(priority, block))
      hooks[name].sort_by!(&:priority)
    end

    # Public: Renders all the view hooks registered for a given hook `name`.
    # Needs a `view_context` parameter, which will almost always be `self` from
    # the helper method or the view that calls this.
    #
    # The easiest is to call this method from within a Helper:
    #
    #    module MyViewHooksRenderHelper
    #      def my_render_hooks(name)
    #        Decidim.view_hooks.render(name, self)
    #      end
    #    end
    #
    #    def ApplicationController
    #      helper MyViewHooksRenderHelper
    #    end
    #
    # Then from your views you need to call `my_render_hooks(name)`.
    #
    # name - The name of the view hook
    # `view_context` - a context to render the view hooks.
    #
    # Returns an HTML safe String.
    def render(name, view_context)
      hooks[name].map do |hook|
        hook.render(view_context)
      end.join.html_safe
    end

    private

    attr_reader :hooks

    # Internal class to encapsulate each view registered on a view hook.
    class ViewHook
      # priority - a Number (Integer|Float) to sort the block.
      # block - a block that will bbe rendered in a view context.
      def initialize(priority, block)
        @priority = priority
        @block = block
      end

      attr_reader :priority

      # Public: renders the block inside the view context.
      #
      # view_context - a context to render the view hook.
      #
      # Returns a String.
      def render(view_context)
        @block.call(view_context)
      end
    end
  end
end
