# frozen_string_literal: true

module Decidim
  # View helpers related to the organization.

  module OrganizationHelper
    include Decidim::TranslatableAttributes

    # Renders a view with the customizable CSS variables in two flavours:
    # 1. as a hexadecimal valid CSS color (ie: #ff0000)
    # 2. as a disassembled RGB components (ie: 255 0 0)
    #
    # Example:
    #
    # --primary: #ff0000;
    # --primary-rgb: 255 0 0
    #
    # Hexadecimal variables can be used as a normal CSS color:
    #
    # color: var(--primary)
    #
    # While the disassembled variant can be used where you need to manipulate
    # the color somehow (ie: adding a background transparency):
    #
    # background-color: rgba(var(--primary-rgb), 0.5)
    def organization_colors
      css = current_organization.colors.each.map { |k, v| "--#{k}: #{v};--#{k}-rgb: #{v[1..2].hex} #{v[3..4].hex} #{v[5..6].hex};" }.join
      render partial: "layouts/decidim/organization_colors", locals: { css: }
    end

    def organization_description_label
      @organization_description_label ||= if empty_organization_description?
                                            t("decidim.pages.home.footer_sub_hero.footer_sub_hero_body_html")
                                          else
                                            decidim_sanitize_admin(translated_attribute(current_organization.description))
                                          end
    end

    def organization_name(organization = current_organization)
      translated_attribute(organization.name, organization)
    end

    def current_organization_name
      organization_name(current_organization)
    end

    private

    def empty_organization_description?
      organization_description = translated_attribute(current_organization.description)

      organization_description.blank? || organization_description == "<p></p>"
    end
  end
end
