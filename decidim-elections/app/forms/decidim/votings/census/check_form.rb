# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # A form to check if data matches census
      class CheckForm < Form
        include Decidim::Votings::Census::CheckFields
        include Decidim::Votings::Census::FrontendFields
      end
    end
  end
end
