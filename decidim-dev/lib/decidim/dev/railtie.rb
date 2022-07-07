# frozen_string_literal: true

require "decidim/rails"

module Decidim
  module Dev
    class Railtie < Rails::Railtie
      railtie_name :decidim_dev

      rake_tasks do
        Decidim::Dev.install_tasks
      end
    end
  end
end
