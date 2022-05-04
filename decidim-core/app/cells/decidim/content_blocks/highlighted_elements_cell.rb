# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedElementsCell < Decidim::ViewModel
      include Decidim::CardHelper

      def elements
        @elements ||= case model.settings.order
                      when "recent"
                        base_relation.order_by_most_recent
                      else
                        base_relation.order_randomly(random_seed)
                      end.limit(limit)
      end

      def base_relation
        raise "Please, overwrite this method. Inheriting classes should define their own base relation"
      end

      def show
        return if elements.blank?

        render
      end

      def published_components
        @published_components ||= if model.scope_name == "participatory_process_group_homepage"
                                    group = Decidim::ParticipatoryProcessGroup.find(model.scoped_resource_id)
                                    Decidim::Component.where(participatory_space: group.participatory_processes).published
                                  else
                                    Decidim::Component.none
                                  end
      end

      def block_id
        "#{model.scope_name}-#{model.manifest_name}".parameterize.gsub("_", "-")
      end

      private

      def limit
        4
      end

      def random_seed
        (rand * 2) - 1
      end
    end
  end
end
