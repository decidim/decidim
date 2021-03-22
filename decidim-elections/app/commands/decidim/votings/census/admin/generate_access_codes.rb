# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to generate and store the access codes for the census data
        class GenerateAccessCodes < Rectify::Command
          def initialize(dataset, user)
            @dataset = dataset
            @user = user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the user is not present
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless valid?

            generate_access_codes
            broadcast(:ok)
          end

          attr_reader :user, :dataset

          def valid?
            user.present? && dataset&.data&.present?
          end

          def generate_access_codes
            dataset.data.find_each do |datum|
              access_code = SecureRandom.alphanumeric(8)
              hashed_online_data = Digest::SHA256.hexdigest([datum.hashed_check_data, access_code].join("."))

              datum.update!(access_code: access_code, hashed_online_data: hashed_online_data)
            end
          end
        end
      end
    end
  end
end
