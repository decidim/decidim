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
        html += t("assemblies.show.open_field.#{assembly.open_field}", scope: "decidim").to_s.html_safe
        unless assembly.open?
          html += ", #{t("assemblies.show.public_field.#{assembly.public_field}", scope: "decidim")}".html_safe
          html += ", #{t("assemblies.show.transparent_field.#{assembly.transparent_field}", scope: "decidim")}".html_safe
          html += " #{decidim_sanitize translated_attribute(assembly.special_features)}".html_safe
        end
        html.html_safe
      end
    end
  end
end
