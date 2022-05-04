# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyPresenter < SimpleDelegator
      def hero_image_url
        assembly.attached_uploader(:hero_image).url(host: assembly.organization.host)
      end

      def banner_image_url
        assembly.attached_uploader(:banner_image).url(host: assembly.organization.host)
      end

      def assembly
        __getobj__
      end
    end
  end
end
