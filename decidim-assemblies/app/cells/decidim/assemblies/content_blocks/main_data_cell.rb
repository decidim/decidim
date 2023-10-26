# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include AssembliesHelper
        include Decidim::ComponentPathHelper
        include ActiveLinkTo

        EXTRA_ATTRIBUTES = %w(purpose_of_action internal_organisation composition).freeze

        delegate :short_description, :description, to: :resource
        delegate(*EXTRA_ATTRIBUTES, to: :resource)

        private

        def decidim_assemblies
          Decidim::Assemblies::Engine.routes.url_helpers
        end

        def title_text
          t("title", scope: "decidim.assemblies.assemblies.show")
        end

        def short_description_text
          decidim_sanitize_editor_admin translated_attribute(short_description)
        end

        def description_text
          [decidim_sanitize_editor_admin(translated_attribute(description)), extra_attributes].compact_blank.join("\n")
        end

        def extra_attributes
          EXTRA_ATTRIBUTES.filter_map do |attribute|
            text = translated_attribute(send(attribute))
            next if text.blank? || text == "<p></p>" 

            [
              content_tag(:h3, class: "h4") { t(attribute, scope: "activemodel.attributes.assembly") },
              decidim_sanitize_editor_admin(text)
            ].join("\n")
          end
        end

        def nav_items
          assembly_nav_items(resource)
        end
      end
    end
  end
end
