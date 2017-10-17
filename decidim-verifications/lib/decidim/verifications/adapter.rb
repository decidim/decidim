# frozen_string_literal: true

module Decidim
  module Verifications
    autoload :HandlerWrapper, "decidim/verifications/handler_wrapper"
    autoload :WorkflowWrapper, "decidim/verifications/workflow_wrapper"

    class Adapter
      def self.from_collection(collection)
        collection.map { |e| from_element(e) }
      end

      def self.from_element(element)
        new(element).wrapper
      end

      def initialize(element)
        @element = element
      end

      def wrapper
        manifest_wrapper || handler_wrapper
      end

      def manifest_wrapper
        return unless manifest

        WorkflowWrapper.new(manifest)
      end

      def handler_wrapper
        handler = handler_for(element) || handler_for(element.classify)
        return unless handler

        HandlerWrapper.new(handler)
      end

      private

      def handler_for(name)
        klass = name.constantize
        return unless klass < Decidim::AuthorizationHandler

        klass
      rescue NameError
        nil
      end

      def manifest
        Verifications.find_workflow_manifest(element)
      end

      attr_reader :element
    end
  end
end
