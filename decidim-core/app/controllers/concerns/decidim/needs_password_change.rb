# frozen_string_literal: true

module Decidim
  # Force user to "Change your password" view when they need to change password
  module NeedsPasswordChange
    extend ActiveSupport::Concern

    included do
      before_action :check_password_update_required
    end

    private

    def check_password_update_required
      return unless request.format.html?
      return unless current_user
      return unless current_user.admin?
      return unless Decidim.config.admin_password_strong
      return unless current_user.needs_password_update?
      return if password_update_permitted_path?(request.path)

      redirect_to_change_password
    end

    def password_update_permitted_path?(target_path)
      permitted_paths = [(tos_path if respond_to?(:tos_path, true)),
                         decidim.delete_account_path,
                         decidim.accept_tos_path,
                         decidim.download_your_data_path,
                         decidim.export_download_your_data_path,
                         decidim.download_file_download_your_data_path,
                         decidim.change_password_path].compact
      # ensure that path with or without query string pass
      permitted_paths.find { |el| el.split("?").first == target_path }
    end

    def redirect_to_change_password
      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("decidim.admin.password_change.alert")
      redirect_to decidim.change_password_path
    end
  end
end
