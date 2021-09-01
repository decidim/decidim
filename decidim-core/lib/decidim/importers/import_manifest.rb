# frozen_string_literal: true

module Decidim
  module Importers
    # For importing data from files to components. Every resource type should
    # specify it's own creator, which will be responsible for producing (creating)
    # and finishing (saving) the imported resource.
    class ImportManifest
      include Virtus.model

      attr_reader :name, :manifest

      attribute :form, String, default: nil

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        space or component.
      #
      # manifest - The parent manifest where this import manifest belongs to.
      #
      def initialize(name, manifest)
        @name = name.to_sym
        @manifest = manifest
        @messages = Messages.new
      end

      # Public: Sets the creator when an argument is provided, returns the
      # stored creator otherwise.
      def creator(creator = nil)
        @creator ||= creator || Decidim::Admin::Import::Creator
      end

      DEFAULT_FORMATS = %w(CSV JSON Excel).freeze

      def formats
        DEFAULT_FORMATS
      end

      # Fetch the messages object or yield it for the block when a block is
      # given.
      def messages
        if block_given?
          yield @messages
        else
          @messages
        end
      end

      # Define a message or render the message in the given context.
      #
      # For defining a message:
      #   manifest.message(:title) { I18n.t("decidim.foos.admin.imports.title.answers") }
      #
      # Within the definition block, you can use `self` to refer to the context
      # where the message is displayed but beware that it may also be `nil`.
      #
      # For rendering the message (self = context within a view):
      #   manifest.message(:title)
      #   OR
      #   manifest.message(:title, self)
      #
      # Or alternatively render with extra arguments (self = context within a view):
      #   manifest.message(:resource_name, count: 2)
      #   OR
      #   manifest.message(:resource_name, self, count: 2)
      #
      # Returns either the set value (the block) when defining the message or
      # the message String when rendering the message.
      def message(key, context = nil, extra = {}, &block)
        extra = context if extra.empty? && context.is_a?(Hash)

        if block_given?
          messages.set(key, &block)
        else
          messages.render(key, context, extra)
        end
      end

      # Returns a boolean indicating whether the message exists with the given key.
      def has_message?(key)
        messages.has?(key)
      end

      class Messages
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

        def render(key, context, extra = {})
          context.instance_exec(extra, &@store[key]) if @store[key]
        end
      end
    end
  end
end
