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
      resource_type_icon "Decidim::Comments::Comment"
    end
  end
end
