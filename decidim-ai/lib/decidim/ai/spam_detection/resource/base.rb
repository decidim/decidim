# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Base
          include Decidim::TranslatableAttributes

          delegate :train, :untrain, to: :classifier

          def initialize(classifier)
            @classifier = classifier
          end

          def fields; end

          def batch_train
            query.find_each(batch_size: 100) do |resource|
              classification = resource_hidden?(resource) ? :spam : :ham
              fields.each do |field_name|
                train classification, translated_attribute(resource.send(field_name))
              end
            end
          end

          protected

          attr_reader :classifier

          def resource_hidden?(resource)
            resource.class.included_modules.include?(Decidim::Reportable) && resource.hidden?
          end
        end
      end
    end
  end
end
