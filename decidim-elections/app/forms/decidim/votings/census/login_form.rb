# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # This class holds the data to login with census data
      class LoginForm < Decidim::Form
        include Decidim::Votings::Census::OnlineFields
        include Decidim::Votings::Census::FrontendFields
      end
    end
  end
end
