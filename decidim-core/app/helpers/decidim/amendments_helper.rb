# frozen_string_literal: true

module Decidim
  # A Helper to render and link amendments to resources.
  module AmendmentsHelper
    include RichTextEditorHelper

    TOTAL_STEPS = 2

    # Renders the state of an emendation
    #
    # Returns Html callout.
    def emendation_announcement_for(emendation)
      return unless emendation.emendation?

      cell("decidim/amendable/announcement", emendation)
    end

    # Checks if the user can participate in a participatory space
    # based on its settings related with Decidim::HasPrivateUsers.
    def can_participate_in_private_space?
      return true unless current_participatory_space.class.included_modules.include?(HasPrivateUsers)

      current_participatory_space.can_participate?(current_user)
    end

    # Returns Html action button cards for an emendation
    def emendation_actions_for(emendation)
      return unless amendments_enabled? && can_react_to_emendation?(emendation)

      action_button_card_for(emendation)
    end

    # Returns Html action button cards to ACCEPT/REJECT or to PROMOTE an emendation
    def action_button_card_for(emendation)
      return accept_and_reject_buttons_for(emendation) if allowed_to_accept_and_reject?(emendation)
      return promote_button_for(emendation) if allowed_to_promote?(emendation)
    end

    # Renders the buttons to ACCEPT/REJECT an emendation
    def accept_and_reject_buttons_for(emendation)
      cell("decidim/amendable/emendation_actions", emendation)
    end

    # Renders the button to PROMOTE an emendation
    def promote_button_for(emendation)
      cell("decidim/amendable/promote_button_card", emendation)
    end

    def amendments_enabled?
      current_component.settings.amendments_enabled
    end

    # Checks if there is a user that can react to an emendation
    def can_react_to_emendation?(emendation)
      return unless current_user && emendation.emendation?

      current_component.current_settings.amendment_reaction_enabled
    end

    # Checks if the user can accept and reject the emendation
    def allowed_to_accept_and_reject?(emendation)
      return unless emendation.amendment.evaluating?

      emendation.amendable.created_by?(current_user) || current_user.admin?
    end

    # Checks if the user can promote the emendation
    def allowed_to_promote?(emendation)
      return unless emendation.amendment.rejected? && emendation.created_by?(current_user)
      return if emendation.amendment.promoted?

      current_component.current_settings.amendment_promotion_enabled
    end

    # Return the translated attribute name to use as label in a form.
    # Returns a String.
    def amendments_form_fields_label(attribute)
      model_name = amendable.model_name.singular_route_key
      I18n.t(attribute, scope: "activemodel.attributes.#{model_name}")
    end

    def amendments_form_field_for(attribute, form, original_resource)
      options = {
        label: amendments_form_fields_label(attribute),
        value: amendments_form_fields_value(original_resource, attribute)
      }

      case attribute
      when :title
        form.text_field(:title, options)
      when :body
        text_editor_for(form, :body, options)
      end
    end

    # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
    def render_emendation_body(emendation)
      body = present(emendation).body(links: true, strip_tags: !rich_text_editor_in_public_views?)
      body = simple_format(body, {}, sanitize: false)

      return body unless rich_text_editor_in_public_views?

      decidim_sanitize_editor(body)
    end

    # Return the edited field value or presents the original attribute value in a form.
    #
    # original_resource - name of the method to send to the controller (:amendable or :emendation)
    # attribute         - name of the attribute to send to the original_resource Presenter
    #
    # Returns a String.
    def amendments_form_fields_value(original_resource, attribute)
      return params[:amendment][:emendation_params][attribute] if params[:amendment].present?

      present(send(original_resource)).send(attribute)
    end

    def total_steps = TOTAL_STEPS

    def current_step
      @current_step ||= case params[:action].to_sym
                        when :new, :create, :edit_draft, :update_draft, :destroy_draft
                          1
                        when :preview_draft, :publish_draft
                          2
                        end
    end

    # Returns the translation of the header title.
    def wizard_header_title
      key = case current_step
            when 1
              :new
            when 2
              :preview_draft
            end

      t("decidim.amendments.#{key}.title")
    end

    # Returns the link we want the back button to point to.
    def wizard_aside_back_url(amendable)
      case current_step
      when 1
        Decidim::ResourceLocatorPresenter.new(amendable).path
      when 2
        Decidim::Core::Engine.routes.url_helpers.edit_draft_amend_path(amendable.amendment)
      end
    end
  end
end
