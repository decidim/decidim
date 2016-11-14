# frozen_string_literal: true
require "decidim/components/base_manifest"

module Decidim
  module Pages
    class ComponentManifest < Decidim::Components::BaseManifest
      name :pages
      engine Engine

      attribute :content, type: :i18n_text
    end
  end
end
