# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      delegate :url, to: :hero_image, prefix: true
      delegate :url, to: :banner_image, prefix: true

      def hero_image_url
        uri = URI(assembly.hero_image.file.file)
        return uri unless uri.scheme.nil?

        URI.join(decidim.root_url(host: assembly.organization.host), assembly.hero_image_url).to_s
      end

      def banner_image_url
        uri = URI(assembly.hero_image.file.file)
        return uri unless uri.scheme.nil?

        URI.join(decidim.root_url(host: assembly.organization.host), assembly.hero_image_url).to_s
      end

      def assembly
        __getobj__
      end
    end
  end
end
