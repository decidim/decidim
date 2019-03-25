# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage newsletters in admin layout
    module NewslettersHelper

      def participatory_spaces_for_select
        html = ""
        Decidim.participatory_space_manifests.each do |manifest|
          spaces = spaces_for_select(manifest.name)
          html+= select_tag_participatory_spaces(manifest.name, spaces)
        end

        html.html_safe
      end

      def select_tag_participatory_spaces manifest_name, spaces

        html = "<div class='row column'>"
          html += manifest_name.to_s
          if spaces
            html += select_tag "#{manifest_name}_ids".to_sym,
                            options_for_select(spaces),
                            { include_blank: true, multiple: true, class: "chosen-select" }

          end
        html += "</div>"
        html.html_safe
      end

      def spaces_for_select manifest_name
        return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)
        spaces ||= Decidim.find_participatory_space_manifest(manifest_name)
                                         .participatory_spaces.call(current_organization)&.order(title: :asc)&.map do |space|
          [
            translated_attribute(space.title),
            space.id
          ]
        end
        spaces << ["Tots","tots"]
      end
    end
  end
end
