# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      attribute :file

      validates :file, presence: true
    end
  end
end
