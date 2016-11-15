# frozen_string_literal: true
module Decidim
  module Pages
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Pages::Admin

      routes do
        post "/", to: "pages#update", as: :page
        root to: "pages#edit"
      end
    end
  end
end
