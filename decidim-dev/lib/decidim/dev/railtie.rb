# frozen_string_literal: true
module Decidim
  module Dev
    class Railtie < Rails::Railtie
      railtie_name :decidim_dev

      rake_tasks do
        Dir[File.join(File.dirname(__FILE__), "../../tasks/*.rake")].each do |file|
          load file
        end
      end
    end
  end
end
