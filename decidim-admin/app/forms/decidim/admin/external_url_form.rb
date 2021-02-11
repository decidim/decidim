# frozen_string_literal: true

module Decidim
  module Admin
    class ExternalUrlForm < Form
      mimic :feedback_recipient

      attribute :url, String
      attribute :position, Integer
      attribute :deleted, Boolean, default: false

      validates :url, presence: true, unless: :deleted

      def to_param
        return id if id.present?

        "url-id"
      end
    end
  end
end
