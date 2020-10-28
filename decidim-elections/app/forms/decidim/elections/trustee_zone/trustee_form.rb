# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This class holds a form to modify trustee information.
      class TrusteeForm < Decidim::Form
        mimic :trustee

        attribute :public_key, String
        validates :public_key, presence: true
        validate :dont_change_public_key

        def dont_change_public_key
          errors.add :public_key, :cant_be_changed if trustee.public_key.present?
        end

        def trustee
          @trustee ||= context[:trustee]
        end
      end
    end
  end
end
