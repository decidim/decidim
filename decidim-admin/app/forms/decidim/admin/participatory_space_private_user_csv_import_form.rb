# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      include Decidim::HasUploadValidations
      include Decidim::HasFileBlob

      attribute :file
      attribute :user_name, String
      attribute :email, String

      validates :file, presence: true
      validate :validate_csv

      def validate_csv
        return if file.blank?

        CSV.foreach(ActiveStorage::Blob.service.path_for(blob.key)) do |_email, user_name|
          errors.add(:user_name, :invalid) unless user_name.match?(UserBaseEntity::REGEXP_NAME)
        end
      end
    end
  end
end
