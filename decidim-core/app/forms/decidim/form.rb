# frozen_string_literal: true

module Decidim
  # A base form object to hold common logic, like automatically adding as
  # public method the params sent as context by the `FormFactory` concern.
  class Form < Rectify::Form
    delegate :current_organization,
             :current_user,
             :current_feature,
             to: :context, prefix: false, allow_nil: true

    delegate :available_locales, to: :current_organization, allow_nil: true

    # Retrieves current participatory space scope (if this is Scopable or has the scope property).
    #
    # Returns a Decidim::Scope
    def current_space_scope
      @current_space_scope = current_feature&.participatory_space&.try(:scope) unless defined?(@current_space_scope)
      @current_space_scope
    end
  end
end
