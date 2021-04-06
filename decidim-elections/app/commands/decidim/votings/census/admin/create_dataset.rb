# frozen_string_literal: true

require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create census dataset for a
        # voting space.
        class CreateDataset < Rectify::Command
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

            if dataset
              CSV.foreach(form.file.tempfile.path, col_sep: ";") do |row|
                CreateDatumJob.perform_later(current_user, dataset, row)
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
                file: form.file.original_filename,
                csv_row_raw_count: csv_row_count,
                status: :creating_data
              },
              visibility: "admin-only"
            )
          end

          def csv_rows
            @csv_rows ||= CSV.read(form.file.tempfile.path)
          end

          def csv_row_count
            @csv_row_count ||= csv_rows.count
          end
        end
      end
    end
  end
end
