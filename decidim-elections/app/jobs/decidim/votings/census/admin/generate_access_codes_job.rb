# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        class GenerateAccessCodesJob < ApplicationJob
          queue_as :default

          def perform(dataset, user)
            return unless user_valid?(user) && dataset_valid?(dataset)

            update_dataset_status(dataset, :generate_codes, user)

            GenerateAccessCodes.call(dataset, user)

            update_dataset_status(dataset, :export_codes, user)
          end

          private

          def user_valid?(user)
            user.present?
          end

          def dataset_valid?(dataset)
            dataset.present? && dataset.review_data_status?
          end

          def update_dataset_status(dataset, status, user)
            UpdateDataset.call(dataset, { status: status }, user)
          end
        end
      end
    end
  end
end
