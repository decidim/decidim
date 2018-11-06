# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conferences from the admin
      # dashboard.
      #
      class DiplomaForm < Form
        mimic :conference

        attribute :main_logo
        attribute :remove_main_logo
        attribute :signature
        attribute :remove_signature
        attribute :signature_name, String
        attribute :sign_date, Decidim::Attributes::LocalizedDate

        validates :signature_name, :sign_date, presence: true

        validates :main_logo, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
        validates :signature, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
      end
    end
  end
end
