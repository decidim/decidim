# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies layout.
    module AssembliesHelper
      include Decidim::ResourceHelper
      # Public: Returns the characteristics of an assembly in a readable format like
      # "title: close, no public, no transparent and is restricted to the members of the assembly"
      def assembly_features(assembly)
        html = "".html_safe
        html += "<strong>#{translated_attribute(assembly.title)}: </strong>".html_safe
        html += t("assemblies.show.is_open.#{assembly.is_open}", scope: "decidim").to_s.html_safe
        unless assembly.is_open?
          html += ", #{t("assemblies.show.is_public.#{assembly.is_public}", scope: "decidim")}".html_safe
          html += ", #{t("assemblies.show.is_transparent.#{assembly.is_transparent}", scope: "decidim")}".html_safe unless assembly.is_public?
          html += " #{decidim_sanitize translated_attribute(assembly.special_features)}".html_safe
        end
        html.html_safe
      end

      def social_handler_links(assembly)
        html = "".html_safe
        if Decidim::Assembly::SOCIAL_HANDLERS.any? { |h| assembly.try("#{h}_handler").present? }
          html += "<div class='definition-data__item social_networks'>".html_safe
          html += "<span class='definition-data__title'>#{t("assemblies.show.social_networks", scope: "decidim")}</span>".html_safe
          Decidim::Assembly::SOCIAL_HANDLERS.each do |handler|
            handler_name = "#{handler}_handler"
            if assembly.send(handler_name).present?
              html += link_to handler.capitalize, "https://#{handler}.com/#{assembly.send(handler_name)}", target: "_blank", class: "", title: handler.capitalize
            end
          end
        end
        html += "</div>".html_safe
        html.html_safe
      end
    end
  end
end
