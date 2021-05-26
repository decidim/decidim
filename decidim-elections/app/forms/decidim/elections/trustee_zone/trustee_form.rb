# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # This class holds a form to modify trustee information.
      class TrusteeForm < Decidim::Form
        mimic :trustee

        attribute :name, String
        attribute :public_key, String
        validates :name, :public_key, presence: true
        validate :dont_change_data

        def dont_change_data
          errors.add :name, :cant_be_changed if trustee.name.present?
          errors.add :public_key, :cant_be_changed if trustee.public_key.present?
        end

        def trustee
          @trustee ||= context[:trustee]
        end
      end
    end
  end
end
