# frozen_string_literal: true

module Decidim
  class PrivateDownloadsController < Decidim::ApplicationController
    before_action :authenticate_user!

    def show
      return head :not_found unless private_download.attached?
      return head :not_found unless private_download.authorized_for?(current_user)

      disposition = private_download.attachment.content_type.start_with?("image/") ? :inline : :attachment

      send_data(
        private_download.attachment.download,
        filename: private_download.attachment.filename.to_s,
        type: private_download.attachment.content_type,
        disposition:
      )
    rescue Decidim::PrivateDownload::InvalidTokenError
      head :not_found
    end

    private

    def private_download
      @private_download ||= Decidim::PrivateDownload.from_token(params[:id])
    end
  end
end
