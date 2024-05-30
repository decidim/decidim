# frozen_string_literal: true

module Decidim
  class AttachmentsUploadTabCell < Decidim::ViewModel
    alias form model

    def show
      render :show
    end
  end
end
