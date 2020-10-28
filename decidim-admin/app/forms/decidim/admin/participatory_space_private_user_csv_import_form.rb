# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      attribute :file
      attribute :user_name, String
      attribute :email, String

      validates :file, presence: true
      validate :validate_csv

      def validate_csv
        if file.present?
          CSV.foreach(file.path) do |email, user_name|
            errors.add(:user_name, :invalid) unless user_name.match?(UserBaseEntity::REGEXP_NAME)
            errors.add(:email, :taken) if context && context.current_organization && context.current_organization.admins.exists?(email: email)
          end
        end
      end
    end
  end
end
