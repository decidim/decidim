# frozen_string_literal: true

module Decidim
  class CommentsButtonCell < ButtonCell
    delegate :current_settings, :component_settings, to: :controller

    def show
      if options.has_key?(:display)
        return render if options[:display]

        return
      end

      render if component_settings.comments_enabled? && !current_settings.try(:comments_blocked?)
    end

    private

    def path
      "#comments"
    end

    def text
      t("decidim.comments.comments_title")
    end

    def icon_name
      resource_type_icon_key "Decidim::Comments::Comment"
    end
  end
end
