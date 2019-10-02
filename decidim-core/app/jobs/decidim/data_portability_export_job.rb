# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, format)
      path = Rails.root.join("tmp/#{user.data_portability_filename}")
      password = SecureRandom.urlsafe_base64

      DataPortabilityExporter.new(user, path, format, password).export
      DataPortabilityUploader.new.store!(File.open(path, "rb"))
      ExportMailer.data_portability_export(user, password).deliver_later
    end
  end
end
