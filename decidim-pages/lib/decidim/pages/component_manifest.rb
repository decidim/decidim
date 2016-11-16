# frozen_string_literal: true
require "decidim/components/base_manifest"

module Decidim
  module Pages
    class ComponentManifest < Decidim::Components::BaseManifest
      component_name :pages
      engine Engine
      admin_engine AdminEngine

      on(:create) do |component|
        Pages::CreatePage.call(component) do
          on(:error) { raise "Can't create page" }
        end
      end

      on(:destroy) do |component|
        Pages::DestroyPage.call(component) do
          on(:error) { raise "Can't destroy page" }
        end
      end
    end
  end
end
