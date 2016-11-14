# frozen_string_literal: true
module Decidim
  module Pages
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pages

      routes do
        root to: "application#show"
      end
    end
  end
end
