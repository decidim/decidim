# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterParticipatorySpaceTypeForm < Form
      attribute :manifest_name, String
      attribute :ids, Array

      def map_model(model_hash)
        manifest = model_hash[:manifest]

        self.manifest_name = manifest.name.to_s
      end
    end
  end
end
