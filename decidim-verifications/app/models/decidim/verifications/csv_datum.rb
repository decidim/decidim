# frozen_string_literal: true

module Decidim
  module Verifications
    class CsvDatum < ApplicationRecord
      belongs_to :organization, foreign_key: :decidim_organization_id,
                                class_name: "Decidim::Organization"

      def self.inside(organization)
        where(decidim_organization_id: organization.id)
      end

      def self.search_user_email(organization, email)
        inside(organization)
          .where(email: email)
          .order(created_at: :desc, id: :desc)
          .first
      end

      def self.insert_all(organization, values)
        columns = %w(email decidim_organization_id created_at updated_at).join(",")
        now = Time.current
        values = values.map do |row|
          "('#{row[0]}','#{organization.id}','#{now}','#{now}')"
        end
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
      end

      def self.clear(organization)
        inside(organization).delete_all
      end
    end
  end
end
