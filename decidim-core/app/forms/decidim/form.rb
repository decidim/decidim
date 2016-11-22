# frozen_string_literal: true
module Decidim
  # A base form object to hold common logic, like automatically adding as
  # public method the params sent as context by the `FormFactory` concern.
  class Form < Rectify::Form
    attr_reader :current_organization, :current_user

    def initialize(attributes = {})
      @current_organization = attributes.delete("current_organization")
      @current_user = attributes.delete("current_user")
      super
    end
  end
end
