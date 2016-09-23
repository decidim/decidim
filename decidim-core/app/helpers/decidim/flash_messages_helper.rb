module Decidim
  # Helper meant to deal with flash messages and other notifications.
  # 
  module FlashMessagesHelper
    FLASH_MAPPINGS = {
      notice: "primary",
      alert: "warning",
      error: "alert",
      success: "success"
    }.freeze

    def flash_messages
      messages = []

      flash.each do |key, message|
        messages.push content_tag(:div, message, class: "callout #{FLASH_MAPPINGS[key.to_sym]}")
      end

      messages.join.html_safe
    end
  end
end
