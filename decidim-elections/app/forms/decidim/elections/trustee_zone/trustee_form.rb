# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This class holds a form to modify trustee information.
      class TrusteeForm < Decidim::Form
        mimic :trustee

        attribute :public_key, String

        validates :public_key, presence: true
      end
    end
  end
end
