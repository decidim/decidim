# frozen_string_literal: true

module Decidim
  module Admin
    # A form to validate the date range for authorization exports
    class AuthorizationExportsForm < Form
      include TranslatableAttributes

      attribute :start_date, Decidim::Attributes::LocalizedDate
      attribute :end_date, Decidim::Attributes::LocalizedDate
      attribute :authorization_handler_name, String

      validates :start_date, presence: true
      validates :end_date, presence: true
    end
  end
end
