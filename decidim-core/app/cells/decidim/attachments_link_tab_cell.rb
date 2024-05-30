# frozen_string_literal: true

module Decidim
  class AttachmentsLinkTabCell < Decidim::ViewModel
    alias form model

    def show
      render :show
    end

    private

    def explanation
      "Add a link to the attachment."
    end

    def help_messages
      [
        "What guidelines do we want to include?",
        "What are the steps to follow?"
      ]
    end
  end
end
