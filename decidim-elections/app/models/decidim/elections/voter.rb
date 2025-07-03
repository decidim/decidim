# frozen_string_literal: true

module Decidim
  module Elections
    class Voter < Elections::ApplicationRecord
      belongs_to :election, class_name: "Decidim::Elections::Election"

      has_many :votes, class_name: "Decidim::Elections::Vote", foreign_key: :decidim_elections_voter_id, dependent: :destroy

      validates :data, presence: true

      scope :with_email, ->(email) { where("data ->> 'email' = ?", email) }

      def self.bulk_insert(election, values)
        values.each { |data| create(election:, data: data.transform_keys(&:to_s)) }
      end

      def email
        data["email"]
      end

      def token
        data["token"]
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
