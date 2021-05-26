# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      class ImportResultsCsvJob < ApplicationJob
        queue_as :exports

        def perform(current_user, current_component, csv_file)
          importer = Decidim::Accountability::ResultsCsvImporter.new(current_component, csv_file, current_user)

          errors = importer.import!

          Decidim::Accountability::ImportMailer.import(current_user, errors).deliver_now
        end
      end
    end
  end
end
