# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class UserBaseEntity < Base
          def fields = [:about]

          protected

          def query = Decidim::UserBaseEntity

          def resource_hidden?(resource) = resource.class.included_modules.include?(Decidim::UserReportable) && resource.blocked?

          def classifier
            @classifier ||= Decidim::Ai::SpamDetection.user_classifier
          end

          def train(category, text)
            raise error_message("Decidim::Ai::SpamDetection.user_detection_service", __method__) unless classifier.respond_to?(:train)

            classifier.train(category, text)
          end

          def untrain(category, text)
            raise error_message("Decidim::Ai::SpamDetection.user_detection_service", __method__) unless classifier.respond_to?(:untrain)

            classifier.train(category, text)
          end
        end
      end
    end
  end
end
