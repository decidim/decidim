# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to update conference diploma configuration
      # from the admin dashboard
      #
      class DiplomaForm < Form
        include Decidim::HasUploadValidations

        mimic :conference

        attribute :main_logo
        attribute :signature
        attribute :signature_name, String
        attribute :sign_date, Decidim::Attributes::LocalizedDate

        validates :signature_name, :sign_date, :main_logo, :signature, presence: true

        validates :main_logo, passthru: { to: Decidim::Conference }
        validates :signature, passthru: { to: Decidim::Conference }

        alias organization current_organization
      end
    end
  end
end
