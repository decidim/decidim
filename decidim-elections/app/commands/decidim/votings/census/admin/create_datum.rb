# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create the datum for a
        # dataset row.
        class CreateDatum < Rectify::Command
          def initialize(form, dataset)
            @form = form
            @dataset = dataset
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless form.valid?

            create_census_datum!
            broadcast(:ok)
          end

          attr_reader :form, :dataset

          def create_census_datum!
            attributes = {
              hashed_in_person_data: form.hashed_in_person_data,
              hashed_check_data: form.hashed_check_data,

              full_name: form.full_name,
              full_address: form.full_address,
              postal_code: form.postal_code,
              mobile_phone_number: form.mobile_phone_number,
              email: form.email,
              decidim_votings_ballot_style_id: form.ballot_style_id
            }

            Decidim::Votings::Census::Datum.create(
              dataset: dataset,
              attributes: attributes
            )
          end
        end
      end
    end
  end
end
