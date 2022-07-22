# frozen_string_literal: true

module Decidim
  # A Helper for views with Followable resources.
  module FollowableHelper
    # Invokes the decidim/shared/follow_button partial.
    def follow_button_for(model, large = nil, opts = {})
      controller.view_context.render(
        partial: "decidim/shared/follow_button",
        locals: { followable: model, large: , opts: opts.slice(:button_classes, :text_classes, :icon_classes) }
      )
    end
  end
end
