# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CollaborativeTexts

      routes do
        resources :documents
      end
    end
  end
end
