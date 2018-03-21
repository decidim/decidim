# frozen_string_literal: true

module Decidim
  # Default permissions class for all components and spaces. It authorizes all
  # actions by any kind of user.
  class DefaultPermissions
    def initialize(*); end

    def allowed?
      true
    end
  end
end
