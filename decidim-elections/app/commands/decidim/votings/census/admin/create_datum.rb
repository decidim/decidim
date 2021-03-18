# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create the datum for a
        # dataset row.
        class CreateDatum < Rectify::Command
          def initialize(form, dataset, user)
            @form = form
            @dataset = dataset
            @voting = dataset.voting
            @user = user
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

          attr_reader :form, :dataset, :voting, :user

          def create_census_datum!
            attributes = {
              hashed_booth_data: hashed_booth_data,
              hashed_personal_data: hashed_personal_data,
              full_name: form.full_name,
              full_address: form.full_address,
              postal_code: form.postal_code,
              mobile_phone_number: form.mobile_phone_number,
              email: form.email
            }

            Decidim.traceability.create(
              Decidim::Votings::Census::Datum,
              user,
              {
                dataset: dataset,
                voting: voting,
                attributes: attributes
              },
              visibility: "admin-only"
            )
          end

          def hashed_booth_data
            Digest::SHA256.hexdigest([form.document_number, form.document_type, form.birthdate].join("."))
          end

          def hashed_personal_data
            Digest::SHA256.hexdigest([form.document_number, form.document_type, form.birthdate, form.postal_code].join("."))
          end
        end
      end
    end
  end
end
