# frozen_string_literal: true

require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to update a census dataset.
        #
        # dataset - the Decidim::Votings::Census::Dataset to update
        # attributes - the hash of attibutes to update
        # user - the user performing the action (used for tracing)
        class UpdateDataset < Decidim::Command
          def initialize(dataset, attributes, user)
            @dataset = dataset
            @attributes = attributes
            @user = user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the input wasn't valid and couldn't proceed
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless valid?

            update_census_dataset!

            broadcast(:ok)
          end

          attr_reader :dataset, :attributes, :user

          def valid?
            user.present? && dataset.present? && attributes.present?
          end

          def update_census_dataset!
            Decidim.traceability.update!(
              dataset,
              user,
              attributes
            )
          end
        end
      end
    end
  end
end
