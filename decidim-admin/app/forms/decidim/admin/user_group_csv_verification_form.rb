# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to upload CSV to batch verify user groups.
    #
    class UserGroupCsvVerificationForm < Form
      include Decidim::HasUploadValidations

      attribute :file

      validates :file, presence: true
    end
  end
end
