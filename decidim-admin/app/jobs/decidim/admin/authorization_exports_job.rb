# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationExportsJob < ApplicationJob
      queue_as :default

      def perform(user, authorization_handler_name, start_date, end_date)
        ExportMailer.export(
          user,
          export_file_name,
          export_data(authorization_handler_name, start_date, end_date)
        ).deliver_now
      end

      def export_data(authorization_handler_name, start_date, end_date)
        Decidim::Exporters::CSV.new(
          collection(authorization_handler_name, start_date, end_date),
          serializer
        ).export
      end

      def export_file_name
        "authorizations_export"
      end

      def collection(authorization_handler_name, start_date, end_date)
        Decidim::Authorization.where(
          granted_at: start_date..end_date,
          name: authorization_handler_name
        )
      end

      def serializer
        Decidim::Admin::AuthorizationSerializer
      end
    end
  end
end
