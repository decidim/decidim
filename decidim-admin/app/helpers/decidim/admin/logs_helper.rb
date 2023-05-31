# frozen_string_literal: true

module Decidim
  module Admin
    module LogsHelper
      def participatory_space_options
        Decidim.participatory_space_manifests.map do |manifest|
          model_class = manifest.model_class_name.constantize
          spaces = manifest.participatory_spaces.call(current_organization).map do |space|
            [translated_attribute(space.title), "#{manifest.name}(#{space.id})"]
          end

          [model_class.model_name.human(count: 2), spaces]
        end
      end
    end
  end
end
