# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterParticipatorySpaceTypeForm < Form
      attribute :manifest_name, String
      attribute :ids, Array

      def map_model(model_hash)
        manifest = model_hash[:manifest]

        self.manifest_name = manifest.name.to_s
        
        # self.ids= Decidim.find_participatory_space_manifest(manifest.name)
        #                                  .participatory_spaces.call(current_organization).map do |participatory_space|
        #   SelectiveNewsletterParticipatorySpaceForm.from_model(participatory_space: participatory_space)
        # end
        #
        # raise
      end
    end
  end
end
