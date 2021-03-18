# frozen_string_literal: true

require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        class ProcessDatasetJob < ApplicationJob
          queue_as :default

          def perform(user, dataset, csv_file_path)
            CSV.foreach(csv_file_path, col_sep: ";") do |row|
              CreateDatumJob.perform_later(user, dataset, row)
            end

            # errors = ["error 1", "error B"]

            # ImportMailer.import(user, errors).deliver_now
          end
        end
      end
    end
  end
end
