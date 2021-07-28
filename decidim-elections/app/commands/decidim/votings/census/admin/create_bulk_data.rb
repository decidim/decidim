# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create the datum for a
        # dataset row.
        class CreateBulkData < Rectify::Command
          def initialize(rows, dataset, user)
            @rows = rows
            @dataset = dataset
            @user = user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            errors = create_census_data

            broadcast(:ok, errors)
          end

          attr_reader :rows, :dataset, :user

          private

          def create_census_data
            errors = []
            rows.each do |row|
              # rubocop:disable Rails/SkipsModelValidations
              Dataset.increment_counter(:csv_row_processed_count, dataset.id)
              # rubocop:enable Rails/SkipsModelValidations
              try do
                create_census_datum(row)
              rescue ActiveRecord::RecordInvalid => e
                errors << e.message
              end
            end

            errors
          end

          def create_census_datum(row)
            form = DatumForm.from_params(row)
                                  .with_context(
                                    current_user: user,
                                    dataset: dataset
                                  )

            attributes = {
              hashed_in_person_data: form.hashed_in_person_data,
              hashed_check_data: form.hashed_check_data,

              full_name: form.full_name,
              full_address: form.full_address,
              postal_code: form.postal_code,
              mobile_phone_number: form.mobile_phone_number,
              email: form.email,
              decidim_votings_ballot_style_id: ballot_style_for_code(dataset.voting, form.ballot_style_code)&.id
            }

            Decidim::Votings::Census::Datum.create!(
              dataset: dataset,
              attributes: attributes
            )
          end

          def ballot_style_for_code(voting, code)
            Decidim::Votings::Admin::BallotStyleByVotingCode.for(voting, code)
          end
        end
      end
    end
  end
end
