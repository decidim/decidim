# frozen_string_literal: true

module Decidim
  # A Helper for views with Followable resources.
  module FollowableHelper
    # Invokes the decidim/shared/follow_button partial.
    def follow_button_for(model, large = nil)
      render partial: "decidim/shared/follow_button.html", locals: { followable: model, large: large }
    end
  end
end
