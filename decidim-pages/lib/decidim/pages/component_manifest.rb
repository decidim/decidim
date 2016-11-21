# frozen_string_literal: true
require "decidim/components/base_manifest"

module Decidim
  module Pages
    # This class is the contract between `decidim-core` and `decidim-pages`. It
    # exposes actions to be done after a component is created (like create a
    # page), as well as the two engines (admin and public).
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
