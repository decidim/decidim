# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # A form to check if data matches census
      class InPersonForm < Form
        include Decidim::Votings::Census::InPersonFields
        include Decidim::Votings::Census::FrontendFields

        attribute :verified, Boolean
        attribute :voted, Boolean

        alias verified? verified
        alias voted? voted
      end
    end
  end
end
