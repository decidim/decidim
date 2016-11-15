# frozen_string_literal: true
require "decidim/components/base_manifest"

module Decidim
  module Pages
    class ComponentManifest < Decidim::Components::BaseManifest
      component_name :pages
      engine Engine
      admin_engine AdminEngine
    end
  end
end
