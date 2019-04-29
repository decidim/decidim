# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage newsletters in admin layout
    module NewslettersHelper
      def participatory_spaces_for_select(form_object)
        content_tag :div, class: "grid-x grid-padding-x" do
          @form.participatory_space_types.each do |space_type|
            concat participatory_space_types_form_object(form_object, space_type)
          end
        end
      end

      def participatory_space_types_form_object(form_object, space_type)
        return if spaces_user_can_admin[space_type.manifest_name.to_sym].blank?
        html = ""
        form_object.fields_for "participatory_space_types[#{space_type.manifest_name}]", space_type do |ff|
          html += ff.hidden_field :manifest_name, value: space_type.manifest_name
          html += select_tag_participatory_spaces(space_type.manifest_name, spaces_for_select(space_type.manifest_name.to_sym), ff)
        end
        html.html_safe
      end

      def select_tag_participatory_spaces(manifest_name, spaces, child_form)
        return unless spaces
        content_tag :div, class: "#{manifest_name}-block cell small-12 medium-6" do
          child_form.select :ids, options_for_select(spaces),
                            { prompt: t("select_recipients_to_deliver.none", scope: "decidim.admin.newsletters"),
                              label: t("activerecord.models.decidim/#{manifest_name.singularize}.other"),
                              include_hidden: false },
                            multiple: true, class: "chosen-select"
        end
      end

      def spaces_for_select(manifest_name)
        return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)
        return spaces_user_can_admin[manifest_name] unless current_user.admin?

        [[I18n.t("select_recipients_to_deliver.all_spaces", scope: "decidim.admin.newsletters"), "all"]] + spaces_user_can_admin[manifest_name]
      end

      def selective_newsletter_to(newsletter)
        return content_tag(:strong, t("index.not_sent", scope: "decidim.admin.newsletters"), class: "text-warning") unless newsletter.sent?
        return content_tag(:strong, t("index.all_users", scope: "decidim.admin.newsletters"), class: "text-success") if newsletter.sent? && newsletter.extended_data.blank?
        content_tag :div do
          concat sent_to_users newsletter
          concat sent_to_spaces newsletter
          concat sent_to_scopes newsletter
        end
      end

      def sent_to_users(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat content_tag(:strong, t("index.has_been_sent_to", scope: "decidim.admin.newsletters"), class: "text-success")
          concat content_tag(:strong, t("index.all_users", scope: "decidim.admin.newsletters")) if newsletter.sended_to_all_users?
          concat content_tag(:strong, t("index.followers", scope: "decidim.admin.newsletters")) if newsletter.sended_to_followers?
          concat t("index.and", scope: "decidim.admin.newsletters") if newsletter.sended_to_followers? && newsletter.sended_to_participants?
          concat content_tag(:strong, t("index.participants", scope: "decidim.admin.newsletters")) if newsletter.sended_to_participants?
        end
      end

      def sent_to_spaces(newsletter)
        html = "<p style='margin-bottom:0;'> "
        newsletter.sended_to_partipatory_spaces.try(:each) do |type|
          next if type["ids"].blank?
          html += t("index.segmented_to", scope: "decidim.admin.newsletters", subject: t("activerecord.models.decidim/#{type["manifest_name"].singularize}.other"))
          if type["ids"].include?("all")
            html += "<strong> #{t("index.all", scope: "decidim.admin.newsletters")} </strong>"
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

      def sent_to_scopes(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat t("index.segmented_to", scope: "decidim.admin.newsletters", subject: nil)
          if newsletter.sent_scopes.any?
            newsletter.sent_scopes.each do |scope|
              concat content_tag(:strong, (translated_attribute scope.name).to_s)
            end
          else
            concat content_tag(:strong, t("index.no_scopes", scope: "decidim.admin.newsletters"))
          end
        end
      end

      def organization_participatory_space(manifest_name)
        @organization_participatory_spaces ||= {}
        @organization_participatory_spaces[manifest_name] ||= Decidim.find_participatory_space_manifest(manifest_name)
                                                                     .participatory_spaces.call(current_organization)&.published&.order(title: :asc)
      end

      def spaces_user_can_admin
        @spaces_user_can_admin ||= {}
        Decidim.participatory_space_manifests.each do |manifest|
          organization_participatory_space(manifest.name)&.each do |space|
            next unless space.admins.exists?(id: current_user.id)
            @spaces_user_can_admin[manifest.name] ||= []
            space_as_option_for_select_data = space_as_option_for_select(space)
            @spaces_user_can_admin[manifest.name] << space_as_option_for_select_data unless @spaces_user_can_admin[manifest.name].detect { |x| x == space_as_option_for_select_data }
          end
        end
        @spaces_user_can_admin
      end

      def space_as_option_for_select(space)
        return unless space
        [
          translated_attribute(space.title),
          space.id,
          { class: space.try(:closed?) ? "red" : "green" }
        ]
      end
    end
  end
end
