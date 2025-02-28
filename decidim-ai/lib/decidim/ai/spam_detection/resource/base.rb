# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Base
          include Decidim::TranslatableAttributes

          def fields; end

          def batch_train
            query.find_each(batch_size: 100) do |resource|
              classification = resource_hidden?(resource) ? :spam : :ham

              fields.each do |field_name|
                raise "#{resource.class.name} does not implement #{field_name} as defined in `#{self.class.name}`" unless resource.respond_to?(field_name.to_sym)

                train classification, translated_attribute(resource.send(field_name.to_sym))
              end
            end
          end

          def train(category, text)
            raise error_message("Decidim::Ai::SpamDetection.resource_detection_service", __method__) unless classifier.respond_to?(:train)

            classifier.train(category, text)
          end

          def untrain(category, text)
            raise error_message("Decidim::Ai::SpamDetection.resource_detection_service", __method__) unless classifier.respond_to?(:untrain)

            classifier.untrain(category, text)
          end

          protected

          def error_message(klass, method_name)
            "Invalid Classifier class! The class defined under `#{klass}` does not follow the contract regarding ##{method_name} method"
          end

          def resource_hidden?(resource)
            resource.class.included_modules.include?(Decidim::Reportable) && resource.hidden? && report_reasons.exclude?(resource.reports&.last&.reason)
          end

          def report_reasons
            Decidim::Report::REASONS.excluding("parent_hidden")
          end

          def classifier
            @classifier ||= Decidim::Ai::SpamDetection.resource_classifier
          end
        end
      end
    end
  end
end
