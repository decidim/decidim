# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class RemoveDuplicatesJob < ApplicationJob
        queue_as :default

        def perform(organization)
          duplicated_census(organization).pluck(:email).each do |email|
            CsvDatum.inside(organization)
                    .where(email:)
                    .order(id: :desc)
                    .all(1..-1)
                    .each(&:delete)
          end
        end

        private

        def duplicated_census(organization)
          CsvDatum.inside(organization)
                  .select(:email)
                  .group(:email)
                  .having("count(email)>1")
        end
      end
    end
  end
end
