# frozen_string_literal: true

module Decidim
  class BaseComponent < ViewComponent::Base
    delegate :current_component,
             :current_organization,
             :current_participatory_space,
             :current_user,
             :translated_attribute,
             :icon,
             :decidim_sanitize_admin,
             :decidim,
             :user_signed_in?,
             to: :helpers
  end
end
