# frozen_string_literal: true

module Decidim
  # This class acts as a registry for any code blocks with names and should be
  # used as a singleton through the `Decidim` core module. This allows
  # registering code blocks for different use cases, for example for the
  # authorization transfers.
  class BlockRegistry
    # Provides access to the registered blocks with their names.
    #
    # @return [Hash<Symbol, Proc>] A hash of the currently registered blocks
    #   with their keys as the hash keys and the blocks as the hash values.
    def registrations
      @registrations ||= {}
    end

    # Register a code block with a name and the handler block.
    #
    # @param name [Symbol] The key for the block.
    # @yield The block to be registered for the provided key.
    # @return [Proc] The registered block itself.
    def register(name, &block)
      return unless block_given?

      registrations[name] = block
    end

    # @overload unregister(name)
    #   Unregister a single registered handler with the provided name.
    #   @param name [Symbol] The name of the registered block.
    #   @return [Proc] The originally registered block for the given key.
    # @overload unregister(*names)
    #   Unregister registered handlers with the provided names.
    #   @param names [Array<Symbol>] The names of the registered blocks to be
    #     unregistered.
    #   @return [Array<Proc>] An array of the originally registered blocks.
    def unregister(*names)
      blocks = names.map do |name|
        registrations.delete(name)
      end
      return blocks.first if names.length == 1

      blocks
    end
  end
end
