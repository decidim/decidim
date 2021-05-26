# frozen_string_literal: true

module Decidim
  module Admin
    class ExternalDomainForm < Form
      attribute :value, String
      attribute :position, Integer
      attribute :deleted, Boolean, default: false

      validates :value, presence: true, unless: :deleted

      def to_param
        return id if id.present?

        "external-domain-id"
      end
    end
  end
end
