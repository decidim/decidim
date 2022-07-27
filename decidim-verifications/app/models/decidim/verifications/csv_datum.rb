# frozen_string_literal: true

module Decidim
  module Verifications
    class CsvDatum < ApplicationRecord
      belongs_to :organization, foreign_key: :decidim_organization_id,
                                class_name: "Decidim::Organization"

      validates :email, format: { with: ::Devise.email_regexp }

      def self.inside(organization)
        where(organization:)
      end

      def self.search_user_email(organization, email)
        inside(organization)
          .where(email:)
          .order(created_at: :desc, id: :desc)
          .first
      end

      def self.insert_all(organization, values)
        values.each { |value| create(email: value, organization:) }
      end

      def self.clear(organization)
        inside(organization).delete_all
      end
    end
  end
end
