# frozen_string_literal: true

require "English"
require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create census dataset for a
        # voting space.
        class CreateDataset < Decidim::Command
          include Decidim::ProcessesFileLocally

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

            process_file_locally(form.file) do |file_path|
              @file_path = file_path
              dataset = create_census_dataset!

              if csv_header_invalid?
                dataset.destroy!
                return broadcast(:invalid_csv_header)
              end

              if dataset
                CSV.foreach(file_path, col_sep: ";", headers: true, converters: ->(f) { f&.strip }) do |row|
                  CreateDatumJob.perform_later(current_user, dataset, row.fields)
                end
              end
            end

            broadcast(:ok)
          end

          private

          attr_reader :form, :current_user, :file_path
          attr_accessor :dataset

          def create_census_dataset!
            Decidim.traceability.create(
              Decidim::Votings::Census::Dataset,
              current_user,
              {
                voting: form.current_participatory_space,
                filename: form.file.filename.to_s,
                csv_row_raw_count: csv_row_count,
                status: :creating_data
              },
              visibility: "admin-only"
            )
          end

          def csv_header_invalid?
            headers.blank? || headers != expected_headers
          end

          def headers
            @headers ||= CSV.parse_line(File.open(file_path), col_sep: ";", headers: true, header_converters: :symbol)&.headers
          end

          def no_ballot_headers
            [:document_id, :document_type, :date_of_birth, :full_name, :full_address, :postal_code, :mobile_phone_number, :email_address]
          end

          def ballot_style_headers
            no_ballot_headers.push(:ballot_style_code)
          end

          def expected_headers
            @expected_headers ||= form.current_participatory_space.has_ballot_styles? ? ballot_style_headers : no_ballot_headers
          end

          def csv_row_count
            @csv_row_count ||= file_lines_count - 1
          end

          # count lines in the most resource-efficient way using ruby, handles milions of lines with minimal memory footprint
          def file_lines_count
            lines = 0
            File.foreach(file_path) { lines += 1 }
            lines
          end
        end
      end
    end
  end
end
