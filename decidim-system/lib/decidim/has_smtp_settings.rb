# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module System
    module HasSmtpSettings
      extend ActiveSupport::Concern

      included do

        jsonb_attribute :smtp_settings, [
          [:from, String],
          [:from_email, String],
          [:from_label, String],
          [:user_name, String],
          [:encrypted_password, String],
          [:address, String],
          [:port, Integer],
          [:authentication, String],
          [:enable_starttls_auto, Virtus::Attribute::Boolean]
        ]

        def encrypted_smtp_settings
          smtp_label = smtp_settings[:from_label].blank? ? smtp_settings[:from_email] : smtp_settings[:from_label]
          smtp_settings.merge!({from: "#{smtp_label} <#{smtp_settings[:from_email]}>"})
          smtp_settings.merge({encrypted_password: Decidim::AttributeEncryptor.encrypt(@password)})
        end
      end
    end
  end
end
