# frozen_string_literal: true

module Decidim
  module Admin
    class ExternalDomainForm < Form
      mimic :feedback_recipient

      attribute :url, String
      attribute :position, Integer
      attribute :deleted, Boolean, default: false

      validates :url, presence: true, unless: :deleted

      def to_param
        return id if id.present?

        "external-domain-id"
      end
    end
  end
end
