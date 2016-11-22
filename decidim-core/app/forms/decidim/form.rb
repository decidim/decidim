# frozen_string_literal: true
module Decidim
  # A base form object to hold common logic, like automatically adding as
  # attributes the params sent as context by the `FormFactory` concern.
  class Form < Rectify::Form
    attribute :current_organization, Organization
    attribute :current_user, User
  end
end
