# frozen_string_literal: true

module Decidim
  module Verifications
    class CsvDatum < ApplicationRecord
      include Decidim::Traceable

      belongs_to :organization, foreign_key: :decidim_organization_id,
                                class_name: "Decidim::Organization"

      validates :email, format: { with: ::Devise.email_regexp }
      validates :email, presence: true
      validates :email, uniqueness: { scope: :decidim_organization_id }

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

      def self.log_presenter_class_for(_log)
        Decidim::Verifications::AdminLog::CsvDatumPresenter
      end

      def authorize!
        user = organization.users.available.find_by(email:)

        return unless user

        authorization = Decidim::Authorization.find_or_initialize_by(
          user:,
          name: "csv_census"
        )

        authorization.grant! unless authorization.granted?
      end
    end
  end
end
