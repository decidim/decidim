# frozen_string_literal: true
require "decidim/core"
require "decidim/system"
require "decidim/admin"

# Module declaration.
module Decidim
  # Loads seeds from all engines.
  def self.seed!
    Rails.application.railties.select do |railtie|
      railtie.respond_to?(:load_seed) && railtie.class.name.include?("Decidim::")
    end.each(&:load_seed)
  end
end
