# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module UserProfile
    extend ActiveSupport::Concern

    include NeedsOrganization

    included do
      layout "layouts/decidim/user_profile"
    end
  end
end
