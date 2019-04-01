# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage newsletters in admin layout
    module NewslettersHelper

      def participatory_spaces_for_select f
        html = "<div class='grid-x grid-padding-x'>"
          @form.participatory_space_types.each do |space_type|
            f.fields_for "participatory_space_types[#{space_type.manifest_name}]", space_type do |ff|
              spaces = spaces_for_select(space_type.manifest_name.to_sym)
              html += ff.hidden_field :manifest_name, value: space_type.manifest_name
              html+= select_tag_participatory_spaces(space_type.manifest_name, spaces, ff)
            end
          end
        html += "</div>"
        html.html_safe
      end

      def select_tag_participatory_spaces manifest_name, spaces, ff
        html = "<div class='cell small-12 medium-6'>"
          html += manifest_name.to_s
          if spaces
            html += ff.select :ids,
                            options_for_select(spaces),
                            { prompt: "cap", include_hidden: false },
                            { multiple: true, class: "chosen-select",  }

          end

        html += "</div>"
        html.html_safe
      end

      def spaces_for_select manifest_name
        return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)
        all_spaces = [["Tots","all"]]
        spaces ||= Decidim.find_participatory_space_manifest(manifest_name)
                                         .participatory_spaces.call(current_organization)&.order(title: :asc)&.map do |space|
          [
            translated_attribute(space.title),
            space.id
          ]
        end
        all_spaces + spaces
      end

      def selective_newsletter_to newsletter
        html = "<div>"
          html += sended_to_users newsletter
          html += sended_to_spaces newsletter
          html += sended_to_scopes newsletter
        html+= "</div>"
        html.html_safe
      end

      def sended_to_users newsletter
        html = "<div>"
          html += "<strong>Sended to: </strong>"
          html += "all users" if newsletter.sended_to_all_users?
          html += "followers" if newsletter.sended_to_followers?
          html += " and " if newsletter.sended_to_followers? && newsletter.sended_to_participants?
          html += "participants" if newsletter.sended_to_participants?
        html += "</div>"
        html.html_safe
      end

      def sended_to_spaces newsletter
        html = "<div>"
          newsletter.sended_to_partipatory_spaces.try(:each) do |type|
            next if type["ids"].blank?
            html += "<strong>#{type["manifest_name"]}: </strong>"
            if type["ids"].include?("all")
              html += "All"
            else
              Decidim.find_participatory_space_manifest(type["manifest_name"].to_sym)
                     .participatory_spaces.call(current_organization)&.where(id: type["ids"]).each do |space|
                html += translated_attribute space.title
              end
            end
            html += "<br/>"
          end
        html += "</div>"
        html.html_safe
      end

      def sended_to_scopes newsletter
        html = "<div>"
          if newsletter.sent_scopes.any?
            html += "<strong> Selective to scopes: </strong>"
            newsletter.sent_scopes.each do |scope|
              html += translated_attribute scope.name
            end
          else
            html += "No scopes"
          end
        html += "</div>"
        html.html_safe
      end
    end
  end
end
