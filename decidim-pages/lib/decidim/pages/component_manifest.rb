# frozen_string_literal: true
require "decidim/components/base_manifest"

module Decidim
  module Pages
    class ComponentManifest < Decidim::Components::BaseManifest
      name :pages
      engine Engine
    end
  end
end
