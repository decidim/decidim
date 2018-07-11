# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to validate registration codes from Decidim's admin panel.
      class ValidateRegistrationCodeForm < Decidim::Form
        attribute :code, String

        validates :code, presence: true
      end
    end
  end
end
