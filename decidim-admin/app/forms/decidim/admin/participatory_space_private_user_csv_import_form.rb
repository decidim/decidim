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
        end
      end
    end
  end
end
