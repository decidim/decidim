# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Importer
        class Database
          def self.call
            Decidim::Ai::SpamDetection.resource_models.values.each do |model|
              model.constantize.new.batch_train
            end
          end
        end
      end
    end
  end
end
