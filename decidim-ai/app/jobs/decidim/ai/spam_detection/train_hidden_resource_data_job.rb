# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class TrainHiddenResourceDataJob < ApplicationJob
        include Decidim::TranslatableAttributes

        def perform(resource)
          return unless resource.respond_to?(:hidden?)

          resource.reload

          wrapped = Decidim::Ai::SpamDetection.resource_models[resource.class.name].constantize.new

          if resource.hidden?
            wrapped.fields.each do |field|
              wrapped.untrain :ham, translated_attribute(resource.send(field))
              wrapped.train :spam, translated_attribute(resource.send(field))
            end
          end
        end
      end
    end
  end
end
