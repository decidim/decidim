# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies layout.
    module AssembliesHelper
      include Decidim::ResourceHelper
      include Decidim::AttachmentsHelper
      include Decidim::IconHelper
      include Decidim::WidgetUrlsHelper
      include Decidim::SanitizeHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::FiltersHelper
      include FilterAssembliesHelper

      # Public: Returns the characteristics of an assembly in a readable format like
      # "title: close, no public, no transparent and is restricted to the members of the assembly"
      # deprecated
      def participatory_processes_for_assembly(assembly_participatory_processes)
        html = ""
        html += %( <div class="section"> ).html_safe
        html += %( <h4 class="section-heading">#{t("assemblies.show.related_participatory_processes", scope: "decidim")}</h4> ).html_safe
        html += %( <div class="row small-up-1 medium-up-2 card-grid"> ).html_safe
        assembly_participatory_processes.each do |assembly_participatory_process|
          html += render partial: "decidim/participatory_processes/participatory_process", locals: { participatory_process: assembly_participatory_process }
        end
        html += %( </div> ).html_safe
        html += %( </div> ).html_safe

        html.html_safe
      end

      def assembly_features(assembly)
        html = "".html_safe
        html += "<strong>#{translated_attribute(assembly.title)}: </strong>".html_safe
        html += t("assemblies.show.private_space", scope: "decidim").to_s.html_safe
        html += ", #{t("assemblies.show.is_transparent.#{assembly.is_transparent}", scope: "decidim")}".html_safe if assembly.is_transparent?
        html += " #{decidim_sanitize_editor translated_attribute(assembly.special_features)}".html_safe
        html.html_safe
      end

      def social_handler_links(assembly)
        html = "".html_safe
        if Decidim::Assembly::SOCIAL_HANDLERS.any? { |h| assembly.try("#{h}_handler").present? }
          html += "<div class='definition-data__item social_networks'>".html_safe
          html += "<span class='definition-data__title'>#{t("assemblies.show.social_networks", scope: "decidim")}</span>".html_safe
          Decidim::Assembly::SOCIAL_HANDLERS.each do |handler|
            handler_name = "#{handler}_handler"
            next if assembly.send(handler_name).blank?

            html += link_to handler.capitalize, "https://#{handler}.com/#{assembly.send(handler_name)}",
                            target: "_blank",
                            class: "",
                            title: t("assemblies.show.social_networks_title", scope: "decidim") << " " << handler.capitalize.to_s, rel: "noopener"
          end
          html += "</div>".html_safe
        end

        html.html_safe
      end

      # Items to display in the navigation of a process
      def assembly_nav_items
        components = current_participatory_space.components.published.or(Decidim::Component.where(id: try(:current_component)))

        [
          {
            name: t("assembly_menu_item", scope: "layouts.decidim.assembly_navigation"),
            url: decidim_assemblies.assembly_path(current_participatory_space),
            active: is_active_link?(decidim_assemblies.assembly_path(current_participatory_space), :exclusive)
          },
          *(if current_participatory_space.members.not_ceased.any?
              [{
                name: t("assembly_member_menu_item", scope: "layouts.decidim.assembly_navigation"),
                url: decidim_assemblies.assembly_assembly_members_path(current_participatory_space),
                active: is_active_link?(decidim_assemblies.assembly_assembly_members_path(current_participatory_space), :inclusive)
              }]
            end
           )
        ] + components.map do |component|
          {
            name: translated_attribute(component.name),
            url: main_component_path(component),
            active: is_active_link?(main_component_path(component), :inclusive)
          }
        end
      end
    end
  end
end
