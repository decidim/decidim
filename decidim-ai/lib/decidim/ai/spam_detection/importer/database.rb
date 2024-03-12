# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Importer
        class Database
          def self.call
            service = Decidim::Ai.spam_detection_instance

            Decidim::Ai.trained_models.values.each do |model|
              model.constantize.new(service).batch_train
            end
          end
        end
      end
    end
  end
end
