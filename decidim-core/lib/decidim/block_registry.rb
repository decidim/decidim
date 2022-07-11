# frozen_string_literal: true

module Decidim
  # This class acts as a registry for any code blocks with names and should be
  # used as a singleton through the `Decidim` core module. This allows
  # registering code blocks for different use cases, for example for the
  # authorization transfers.
  class BlockRegistry
    # Provides access to the registered blocks with their names.
    def registrations
      @registrations ||= {}
    end

    # Register a code block with a name and the handler block.
    def register(name, &block)
      return unless block_given?

      registrations[name] = block
    end

    # Unregister registered handlers with the provided names.
    def unregister(*names)
      names.map do |name|
        registrations.delete(name)
      end
    end
  end
end
