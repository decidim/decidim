# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      attribute :file

      validates :file, presence: true
      validate :validate_csv

      def validate_csv
        CSV.foreach(file.path) do |_email, user_name|
          errors.add(:user_name, "user_name not valid!") unless user_name.match?(/\A(?!.*[<>?%&\^*#@\(\)\[\]\=\+\:\;\"\{\}\\\|])/)
          errors.add(:email, :taken) if context && context.current_organization && context.current_organization.admins.where(email: email).exists?
        end
      end
    end
  end
end
