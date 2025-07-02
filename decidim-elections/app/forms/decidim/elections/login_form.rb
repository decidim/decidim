# frozen_string_literal: true

module Decidim
  module Elections
    # This class presents data for logging into the system with census data.
    class LoginForm < Decidim::Form
      attribute :email, String
      attribute :token, String
    end
  end
end
