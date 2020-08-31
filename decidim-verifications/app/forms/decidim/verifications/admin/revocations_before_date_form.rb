# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class RevocationsBeforeDateForm < Decidim::Form
        include TranslatableAttributes

        attribute :impersonated_only, Boolean
        attribute :before_date, Decidim::Attributes::LocalizedDate

        validates :before_date, presence: true
      end
    end
  end
end
