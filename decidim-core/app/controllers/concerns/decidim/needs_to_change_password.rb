# frozen_string_literal: true

module Decidim
  # Shared behaviour for signed_in users that require the latest TOS accepted
  module NeedsToChangePassword
    extend ActiveSupport::Concern

    included do
      before_action :admin_has_strong_password
    end

    private

    def admin_has_strong_password
      return true unless request.format.html?
      return true unless current_user
      return true unless current_user.admin?
      return unless Decidim.config.admin_password_strong_enable
      return if current_user.password_updated_at.present?
      return if permitted_paths?

      redirect_to_edit_admin_password
    end

    def permitted_paths?
      permitted_paths = [tos_path,
                         decidim.delete_account_path,
                         decidim.accept_tos_path,
                         decidim.download_your_data_path,
                         decidim.export_download_your_data_path,
                         decidim.download_file_download_your_data_path,
                         decidim.edit_admin_password_path]
      # ensure that path with or without query string pass
      permitted_paths.find { |el| el.split("?").first == request.path }
    end

    def redirect_to_edit_admin_password
      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("decidim.admin.password_change.alert")
      redirect_to decidim.edit_admin_password_path
    end
  end
end
