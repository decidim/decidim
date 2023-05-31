# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        class GenerateAccessCodesJob < ApplicationJob
          queue_as :default

          def perform(dataset, user)
            return unless user_valid?(user) && dataset_valid?(dataset)

            generate_access_codes(dataset)

            update_dataset_status(dataset, :codes_generated, user)
          end

          private

          def user_valid?(user)
            user.present?
          end

          def dataset_valid?(dataset)
            dataset.present? && dataset.generating_codes?
          end

          def generate_access_codes(dataset)
            dataset.data.find_each do |datum|
              access_code = SecureRandom.alphanumeric(8)
              hashed_online_data = Digest::SHA256.hexdigest([datum.hashed_check_data, access_code].join("."))

              datum.update!(access_code:, hashed_online_data:)
            end
          end

          def update_dataset_status(dataset, status, user)
            UpdateDataset.call(dataset, { status: }, user)
          end
        end
      end
    end
  end
end
