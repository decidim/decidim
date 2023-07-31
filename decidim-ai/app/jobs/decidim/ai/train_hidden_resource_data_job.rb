# frozen_string_literal: true

module Decidim
  module Ai
    class TrainHiddenResourceDataJob < ApplicationJob
      include Decidim::TranslatableAttributes

      def perform(resource)
        return unless resource.respond_to?(:hidden?)

        resource.reload

        wrapped = Decidim::Ai.trained_models[resource.class.name].constantize.new(classifier)

        if resource.hidden?
          wrapped.fields.each do |field|
            classifier.untrain :ham, translated_attribute(resource.send(field))
            classifier.train :spam, translated_attribute(resource.send(field))
          end
        end
      end
    end
  end
end
