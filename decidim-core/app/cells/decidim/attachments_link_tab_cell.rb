# frozen_string_literal: true

module Decidim
  class AttachmentsLinkTabCell < Decidim::ViewModel
    alias form model

    def show
      render :show
    end

    private

    def explanation
      I18n.t("decidim.forms.attachment_link.explanation")
    end

    def help_messages
      I18n.t("decidim.forms.attachment_link.help_messages")
    end
  end
end
