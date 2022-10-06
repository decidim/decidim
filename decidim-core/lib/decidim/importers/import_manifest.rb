# frozen_string_literal: true

module Decidim
  module Importers
    # For importing data from files to components. Every resource type should
    # specify it's own creator, which will be responsible for producing (creating)
    # and finishing (saving) the imported resource.
    class ImportManifest
      include Decidim::AttributeObject::Model

      attr_reader :name, :manifest

      attribute :form_view, String, default: nil
      attribute :form_class_name, String, default: "Decidim::Admin::ImportForm"

      # Initializes the manifest.
      #
      # name - The name of the export artifact. It should be unique in the
      #        space or component.
      #
      # manifest - The parent manifest where this import manifest belongs to.
      #
      def initialize(name, manifest)
        super()
        @name = name.to_sym
        @manifest = manifest
        @messages = ImportManifestMessages.new
      end

      # Public: Sets the creator when an argument is provided, returns the
      # stored creator otherwise.
      def creator(creator = nil)
        @creator ||= creator || Decidim::Admin::Import::Creator
      end

      def form_class
        form_class_name.constantize
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
      def message(key, context = nil, **extra, &)
        extra = context if extra.empty? && context.is_a?(Hash)

        if block_given?
          messages.set(key, &)
        else
          messages.render(key, context, **extra)
        end
      end

      # Returns a boolean indicating whether the message exists with the given key.
      def has_message?(key)
        messages.has?(key)
      end

      # Either define example import data when providing a block or fetch the
      # example data for the given context and component.
      #
      # When defining example data:
      #   manifest.example do |component|
      #     organization = component.organization
      #     [
      #       %w(id name") + organization.available_locales.map { |l| "title/#{l}" },
      #       [1, "John Doe"] + organization.available_locales.map { "Manager" },
      #       [2, "Joanna Doe"] + organization.available_locales.map { "Manager" },
      #     ]
      #   end
      #
      # When fetching example data:
      #   data = manifest.example(self, current_component)
      #
      # Returns either the example data or nothing when defining the example.
      def example(context = nil, component = nil, &block)
        if block_given?
          @example = block
        elsif has_example?
          context.instance_exec(component, &@example)
        end
      end

      # Returns a boolean indicating whether the example is available or not.
      def has_example?
        @example.present?
      end

      class ImportManifestMessages < Decidim::ManifestMessages; end
    end
  end
end
