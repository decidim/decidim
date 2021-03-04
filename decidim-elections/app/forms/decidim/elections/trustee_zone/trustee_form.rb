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
        validate :valid_name

        def dont_change_data
          errors.add :name, :cant_be_changed if trustee.name.present?
          errors.add :public_key, :cant_be_changed if trustee.public_key.present?
        end

        def valid_name
          errors.add :name, :is_taken if Decidim::Elections::Trustee.exists?(name: name)
        end

        def trustee
          @trustee ||= context[:trustee]
        end
      end
    end
  end
end
