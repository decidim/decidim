# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage newsletters in admin layout
    module NewslettersHelper
      def participatory_spaces_for_select(form_object)
        html = "<div class='grid-x grid-padding-x'>"
        @form.participatory_space_types.each do |space_type|
          form_object.fields_for "participatory_space_types[#{space_type.manifest_name}]", space_type do |ff|
            spaces = spaces_for_select(space_type.manifest_name.to_sym)
            html += ff.hidden_field :manifest_name, value: space_type.manifest_name
            html += select_tag_participatory_spaces(space_type.manifest_name, spaces, ff)
          end
        end
        html += "</div>"
        html.html_safe
      end

      def select_tag_participatory_spaces(manifest_name, spaces, child_form)
        return unless spaces
        content_tag :div, class: "cell small-12 medium-6" do
          child_form.select :ids, options_for_select(spaces),
                            { prompt: t("decidim.admin.newsletters.select_recipients_to_deliver.any"),
                              label: t("activerecord.models.decidim/#{manifest_name.singularize}.other"),
                              include_hidden: false },
                            multiple: true, class: "chosen-select"
        end
      end

      def spaces_for_select(manifest_name)
        return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)
        all_spaces = [[I18n.t("decidim.admin.newsletters.select_recipients_to_deliver.all_spaces"), "all"]]
        spaces ||= Decidim.find_participatory_space_manifest(manifest_name)
                          .participatory_spaces.call(current_organization)&.published&.order(title: :asc)&.map do |space|
          [
            translated_attribute(space.title),
            space.id,
            { class: space.try(:closed?) ? "red" : "green" }
          ]
        end
        all_spaces + spaces
      end

      def selective_newsletter_to(newsletter)
        return t("decidim.admin.newsletters.index.not_sent") unless newsletter.sent?
        content_tag :div do
          concat sended_to_users newsletter
          concat sended_to_spaces newsletter
          concat sended_to_scopes newsletter
        end
      end

      def sended_to_users(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat t(".has_been_sent_to")
          concat content_tag(:strong, t(".all_users")) if newsletter.sended_to_all_users?
          concat content_tag(:strong, t(".followers")) if newsletter.sended_to_followers?
          concat t(".and") if newsletter.sended_to_followers? && newsletter.sended_to_participants?
          concat content_tag(:strong, t(".participants")) if newsletter.sended_to_participants?
        end
      end

      def sended_to_spaces(newsletter)
        html = "<p style='margin-bottom:0;'> "
        newsletter.sended_to_partipatory_spaces.try(:each) do |type|
          next if type["ids"].blank?
          html += t(".segmented_to", subject: t("activerecord.models.decidim/#{type["manifest_name"].singularize}.other"))
          if type["ids"].include?("all")
            html += "<strong> #{t(".all")} </strong>"
          else
            Decidim.find_participatory_space_manifest(type["manifest_name"].to_sym)
                   .participatory_spaces.call(current_organization).where(id: type["ids"]).each do |space|
              html += "<strong>#{translated_attribute space.title}</strong>"
            end
          end
          html += "<br/>"
        end
        html += "</p>"
        html.html_safe
      end

      def sended_to_scopes(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat t(".segmented_to", subject: nil)
          if newsletter.sent_scopes.any?
            newsletter.sent_scopes.each do |scope|
              concat content_tag(:strong, (translated_attribute scope.name).to_s)
            end
          else
            concat content_tag(:strong, t(".no_scopes"))
          end
        end
      end
    end
  end
end
