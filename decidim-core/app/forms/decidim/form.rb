# frozen_string_literal: true
module Decidim
  # A base form object to hold common logic, like automatically adding as
  # public method the params sent as context by the `FormFactory` concern.
  class Form < Rectify::Form
    attr_reader :current_organization, :current_user, :current_feature

    def initialize(attributes = {})
      @current_organization = attributes.delete("current_organization") || attributes.delete(:current_organization)
      @current_user = attributes.delete("current_user") || attributes.delete(:current_user)
      @current_feature = attributes.delete("current_feature") || attributes.delete(:current_feature)
      super
    end
  end
end
