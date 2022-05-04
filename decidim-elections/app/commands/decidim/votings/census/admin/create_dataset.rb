# frozen_string_literal: true

require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create census dataset for a
        # voting space.
        class CreateDataset < Decidim::Command
          include Decidim::HasBlobFile

          def initialize(form, current_user)
            @form = form
            @current_user = current_user
            @dataset = nil
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless form.valid?

            dataset = create_census_dataset!

            if csv_header_invalid?
              dataset.destroy!
              return broadcast(:invalid_csv_header)
            end

            if dataset
              CSV.foreach(blob_path, col_sep: ";", headers: true, converters: ->(f) { f&.strip }) do |row|
                CreateDatumJob.perform_later(current_user, dataset, row.fields)
              end
            end

            broadcast(:ok)
          end

          attr_reader :form, :current_user
          attr_accessor :dataset

          def create_census_dataset!
            Decidim.traceability.create(
              Decidim::Votings::Census::Dataset,
              current_user,
              {
                voting: form.current_participatory_space,
                file: blob,
                csv_row_raw_count: csv_row_count,
                status: :creating_data
              },
              visibility: "admin-only"
            )
          end

          def csv_header_invalid?
            CSV.parse_line(File.open(blob_path), col_sep: ";", headers: true, header_converters: :symbol).headers != expected_headers
          end

          def headers
            [:document_id, :document_type, :date_of_birth, :full_name, :full_address, :postal_code, :mobile_phone_number, :email_address]
          end

          def ballot_style_headers
            headers.push(:ballot_style_code)
          end

          def expected_headers
            @expected_headers ||= form.current_participatory_space.has_ballot_styles? ? ballot_style_headers : headers
          end

          def csv_rows
            @csv_rows ||= CSV.read(blob_path)
          end

          def csv_row_count
            @csv_row_count ||= file_lines_count(blob_path) - 1
          end

          def file_lines_count(file_path)
            `wc -l "#{file_path.shellescape}"`.strip.split(" ")[0].to_i
          end
        end
      end
    end
  end
end
