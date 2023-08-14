# frozen_string_literal: true

namespace :decidim do
  namespace :content_blocks do
    desc "Initializes a default set of content blocks for each space whose landing page uses content blocks"
    task :initialize_default_content_blocks, [:manifest_name, :space_id, :include_components] => :environment do |_task, args|
      manifest_name = args[:manifest_name]
      space_id = args[:space_id]&.to_i

      raise "Please, provide a valid manifest name to find the space by id" if space_id.present? && manifest_name.blank?

      include_components = args[:include_components] == "true"

      valid_manifests = manifests_with_content_blocks
      valid_manifests = valid_manifests.select { |manifest| manifest.name.to_s == manifest_name.to_s } if manifest_name.present?

      raise "The #{manifest_name} spaces do not exist or have content blocks" if manifest_name.present? && valid_manifests.blank?

      valid_manifests.each do |manifest|
        spaces = resources_for(manifest)
        spaces = spaces.select { |space| space.id == space_id } if space_id.present?

        spaces.each do |space|
          content_blocks_creator = Decidim::ContentBlocksCreator.new(space)
          content_blocks_creator.create_default!

          content_blocks_creator.create_components_blocks! if include_components
        end
      end
    end

    def manifests_with_content_blocks
      [
        Decidim.participatory_space_manifests,
        Decidim.resource_manifests
      ].map do |manifests|
        manifests.select { |manifest| manifest.content_blocks_scope_name.present? }
      end.flatten
    end

    def resources_for(manifest)
      return manifest.participatory_spaces.call(Decidim::Organization.all) if manifest.respond_to?(:participatory_spaces)
      return manifest.model_class.all if manifest.respond_to?(:model_class)

      []
    end
  end
end
