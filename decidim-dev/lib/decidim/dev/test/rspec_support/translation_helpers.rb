# frozen_string_literal: true

# A collection of methods to help dealing with translated attributes.
module TranslationHelpers
  # Allows using the `t` shortcut inside specs just like in views
  def t(key, scope: nil)
    I18n.t(key, scope: scope, raise: true)
  end

  # Gives the localized version of the attribute for the given locale. The
  # locale defaults to the application's default one.
  #
  # It is intended to be used to avoid the implementation details, so that the
  # translated attributes implementation can change more easily.
  def translated(field, locale: I18n.locale)
    field.try(:[], locale.to_s)
  end

  # Checks that the current page has some translated content. It strips the
  # HTML tags from the field (in case there are any).
  #
  # field - the field that holds the translations
  # locale - the ID of the locale to check
  # upcase - a boolean to indicate whether the string must be checked upcased or not.
  def have_i18n_content(field, locale: I18n.locale, upcase: false)
    have_content(i18n_content(field, locale: locale, upcase: upcase))
  end

  # Checks that the current page doesn't have some translated content. It strips
  # the HTML tags from the field (in case there are any).
  #
  # field - the field that holds the translations
  # locale - the ID of the locale to check
  # upcase - a boolean to indicate whether the string must be checked upcased or not.
  def have_no_i18n_content(field, locale: I18n.locale, upcase: false)
    have_no_content(i18n_content(field, locale: locale, upcase: upcase))
  end

  # Handles how to fill in i18n form fields.
  #
  # field - the name of the field that should be filled, without the
  #   locale-related part (e.g. `:participatory_process_title`)
  # tab_selector - a String representing the ID of the HTML element that holds
  #   the tabs for this input. It ususally is `"#<attribute_name>-tabs" (e.g.
  #   "#title-tabs")
  # localized_values - a Hash where the keys are the locales IDs and the values
  #   are the values that will be entered in the form field.
  def fill_in_i18n(field, tab_selector, localized_values)
    fill_in_i18n_fields(field, tab_selector, localized_values) do |locator, value|
      fill_in locator, with: value
    end
  end

  # Handles how to fill in i18n form fields which uses a WYSIWYG editor.
  #
  # field - the name of the field that should be filled, without the
  #   locale-related part (e.g. `:participatory_process_title`)
  # tab_selector - a String representing the ID of the HTML element that holds
  #   the tabs for this input. It ususally is `"#<attribute_name>-tabs" (e.g.
  #   "#title-tabs")
  # localized_values - a Hash where the keys are the locales IDs and the values
  #   are the values that will be entered in the form field.
  def fill_in_i18n_editor(field, tab_selector, localized_values)
    fill_in_i18n_fields(field, tab_selector, localized_values) do |locator, value|
      fill_in_editor locator, with: value
    end
  end

  # Handles how to fill a WYSIWYG editor.
  #
  # locator - The input field ID. The DOM element is selected using jQuery.
  # params  - A Hash of options
  #          :with - A String value that will be entered in the form field. (required)
  def fill_in_editor(locator, params = {})
    raise ArgumentError if params[:with].blank?
    page.execute_script <<-SCRIPT
      $('##{locator}').siblings('.editor-container').find('.ql-editor')[0].innerHTML = "#{params[:with]}";
      $('##{locator}').val("#{params[:with]}")
    SCRIPT
  end

  private

  def fill_in_i18n_fields(field, tab_selector, localized_values)
    localized_values.each do |locale, value|
      within tab_selector do
        click_link I18n.with_locale(locale) { t("name", scope: "locale") }
      end
      yield "#{field}_#{locale}", value
    end
  end

  # Gives a specific language version of a field and (optionally) upcases it
  #
  # field - the field that holds the translations
  # locale - the ID of the locale to check
  # upcase - a boolean to indicate whether the string must be checked upcased or not.
  def i18n_content(field, locale: I18n.locale, upcase: false)
    content = stripped(translated(field, locale: locale))
    upcase ? content.upcase : content
  end
end
