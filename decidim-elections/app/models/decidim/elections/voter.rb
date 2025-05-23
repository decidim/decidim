# frozen_string_literal: true

module Decidim
  module Elections
    class Voter < Elections::ApplicationRecord
      belongs_to :election, class_name: "Decidim::Elections::Election"

      validates :email, presence: true
      validates :email, format: { with: ::Devise.email_regexp }
      validates :email, uniqueness: { scope: :election_id }
      validates :token, presence: true

      def self.inside(election)
        where(election:)
      end

      def self.search_user_email(election, email)
        inside(election)
          .where(email:)
          .order(created_at: :desc, id: :desc)
          .first
      end

      def self.insert_all(election, values)
        values.each { |value| create(email: value.first.downcase, election:, token: value.second.downcase) }
      end

      def self.clear(election)
        inside(election).delete_all
      end
    end
  end
end
