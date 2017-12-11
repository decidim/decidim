# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module NewslettersHelper

    def parse_interpolations(content, user)
      content.gsub("%{name}", user.name)
    end
  end
end
