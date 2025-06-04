# frozen_string_literal: true

module Decidim
  module Elections
    class Voter < Elections::ApplicationRecord
      belongs_to :election, class_name: "Decidim::Elections::Election"

      validates :data, presence: true

      def self.bulk_insert(election, values)
        values.each { |data| create(election:, data:) }
      end

      def identifier
        if data.is_a?(Hash)
          data[:identifier] || data[:email] || data[:phone_number] || data[:name] || data[:username] || data.values.first
        elsif data.present?
          data.to_s.truncate(50)
        else
          id
        end
      end
    end
  end
end
