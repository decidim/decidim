# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to manage newsletters in admin layout
    module NewslettersHelper
      def find_verification_types_for_select(organization)
        available_verifications = organization.available_authorizations
        available_verifications.map do |verification_type|
          [t("decidim.authorization_handlers.#{verification_type}.name"), verification_type]
        end
      end

      def participatory_spaces_for_select(form_object)
        content_tag :div do
          @form.participatory_space_types.each do |space_type|
            concat participatory_space_types_form_object(form_object, space_type)
          end
        end
      end

      def participatory_space_types_form_object(form_object, space_type)
        return if spaces_user_can_admin[space_type.manifest_name.to_sym].blank?

        html = ""
        form_object.fields_for :participatory_space_types do |parent_form|
          parent_form.fields_for space_type.manifest_name, space_type do |ff|
            html += participatory_space_title(space_type)
            html += ff.hidden_field :manifest_name, value: space_type.manifest_name
            html += select_tag_participatory_spaces(space_type.manifest_name, spaces_for_select(space_type.manifest_name.to_sym), ff)
          end
        end

        html.html_safe
      end

      def participatory_space_title(space_type)
        return unless space_type

        content_tag :h4 do
          t("activerecord.models.decidim/#{space_type.manifest_name.singularize}.other")
        end
      end

      def select_tag_participatory_spaces(manifest_name, spaces, child_form)
        return unless spaces

        raw(cell("decidim/admin/multi_select_picker", nil, context: {
                   select_id: "#{manifest_name}-spaces-select",
                   field_name: "#{child_form.object_name}[ids][]",
                   options_for_select: spaces,
                   selected_values: selected_options(:participatory_space_types)[manifest_name] || [],
                   placeholder: t("select_recipients_to_deliver.select_#{manifest_name}", scope: "decidim.admin.newsletters"),
                   class: "mb-2"
                 }))
      end

      def spaces_for_select(manifest_name)
        return unless Decidim.participatory_space_manifests.map(&:name).include?(manifest_name)
        return spaces_user_can_admin[manifest_name] unless current_user.admin?

        [[I18n.t("select_recipients_to_deliver.all_spaces", scope: "decidim.admin.newsletters"), "all"]] + spaces_user_can_admin[manifest_name]
      end

      def selective_newsletter_to(newsletter)
        return content_tag(:strong, t("index.not_sent", scope: "decidim.admin.newsletters"), class: "text-warning") unless newsletter.sent?
        return content_tag(:strong, t("index.all_users", scope: "decidim.admin.newsletters"), class: "text-success") if newsletter.sent? && newsletter.extended_data.blank?
        return sent_to_verified_users(newsletter) if newsletter.sent_to_verified_users?

        content_tag :div do
          concat sent_to_users newsletter
          concat sent_to_spaces newsletter
        end
      end

      def sent_to_users(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat content_tag(:strong, t("index.has_been_sent_to", scope: "decidim.admin.newsletters"), class: "text-success")

          recipients = []

          recipients << content_tag(:strong, t("index.all_users", scope: "decidim.admin.newsletters")) if newsletter.sent_to_all_users?
          recipients << content_tag(:strong, t("index.verified_users", scope: "decidim.admin.newsletters")) if newsletter.sent_to_verified_users?
          recipients << content_tag(:strong, t("index.followers", scope: "decidim.admin.newsletters")) if newsletter.sent_to_followers?
          recipients << content_tag(:strong, t("index.participants", scope: "decidim.admin.newsletters")) if newsletter.sent_to_participants?
          recipients << content_tag(:strong, t("index.private_members", scope: "decidim.admin.newsletters")) if newsletter.sent_to_private_members?

          concat recipients.join(t("index.and", scope: "decidim.admin.newsletters")).html_safe
        end
      end

      def sent_to_verified_users(newsletter)
        content_tag :p, style: "margin-bottom:0;" do
          concat content_tag(:strong, t("index.has_been_sent_to", scope: "decidim.admin.newsletters"), class: "text-success")
          concat content_tag(:strong, t("index.verified_users", scope: "decidim.admin.newsletters"))
          concat content_tag(:p, t("index.verification_types", scope: "decidim.admin.newsletters", types: selected_verification_types(newsletter)))
        end
      end

      def sent_to_spaces(newsletter)
        html = "<p style='margin-bottom:0;'> "
        newsletter.sent_to_participatory_spaces.try(:each) do |type|
          next if type["ids"].blank?

          ids = parse_ids(type["ids"])

          html += t("index.segmented_to", scope: "decidim.admin.newsletters", subject: t("activerecord.models.decidim/#{type["manifest_name"].singularize}.other"))
          if ids.include?("all")
            html += "<strong> #{t("index.all", scope: "decidim.admin.newsletters")} </strong>"
          else
            Decidim.find_participatory_space_manifest(type["manifest_name"].to_sym)
                   .participatory_spaces.call(current_organization).where(id: ids).each do |space|
              html += "<strong>#{decidim_escape_translated(space.title)}</strong>"
            end
          end
          html += "<br/>"
        end
        html += "</p>"
        html.html_safe
      end

      def organization_participatory_space(manifest_name)
        @organization_participatory_spaces ||= {}
        @organization_participatory_spaces[manifest_name] ||= Decidim
                                                              .find_participatory_space_manifest(manifest_name)
                                                              .participatory_spaces.call(current_organization)
                                                              .published
                                                              .sort_by { |space| [space.try(:closed?) ? 1 : 0, space.title[current_locale]] }
      end

      def spaces_user_can_admin
        @spaces_user_can_admin ||= {}
        Decidim.participatory_space_manifests.each do |manifest|
          organization_participatory_space(manifest.name)&.each do |space|
            next unless space.admins.exists?(id: current_user.id)

            @spaces_user_can_admin[manifest.name] ||= []
            space_as_option_for_select_data = space_as_option_for_select(space)
            @spaces_user_can_admin[manifest.name] << space_as_option_for_select_data unless @spaces_user_can_admin[manifest.name].detect do |x|
              x == space_as_option_for_select_data
            end
          end
        end
        @spaces_user_can_admin
      end

      def space_as_option_for_select(space)
        return unless space

        [
          translated_attribute(space.title),
          space.id,
          { class: space.try(:closed?) ? "red" : "green", title: translated_attribute(space.title).to_s }
        ]
      end

      def newsletter_attention_callout_announcement
        {
          body: t("warning", scope: "decidim.admin.newsletters.select_recipients_to_deliver").html_safe
        }
      end

      def newsletter_recipients_count_callout_announcement
        spinner = "<span id='recipients_count_spinner' class='loading-spinner hide'></span>"
        body = "#{t("recipients_count", scope: "decidim.admin.newsletters.select_recipients_to_deliver", count: recipients_count_query)} #{spinner}"
        {
          body:
        }
      end

      def parse_ids(ids)
        ids.size == 1 && ids.first.is_a?(String) ? ids.first.split.map(&:strip) : ids
      end

      def selected_verification_types(newsletter)
        newsletter.sent_to_users_with_verification_types&.map do |type|
          I18n.t("decidim.authorization_handlers.#{type}.name")
        end&.join(", ")
      end
    end
  end
end
