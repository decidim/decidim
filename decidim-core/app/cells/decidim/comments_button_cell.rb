# frozen_string_literal: true

module Decidim
  class CommentsButtonCell < RedesignedButtonCell
    private

    def path
      # REDESIGN_PENDING: Replace this path
      "#comments"
    end

    def text
      t("decidim.comments.comments_title")
    end

    def icon_name
      "chat-1-line"
    end
  end
end
