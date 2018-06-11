# frozen_string_literal: true

module Decidim
  # Shared behaviour for signed_in users that require the latest TOS accepted
  module NeedsTosAccepted
    extend ActiveSupport::Concern

    included do
      before_action :tos_accepted_by_user
      helper_method :terms_and_conditions_page
    end

    private

    def tos_accepted_by_user
      return true unless current_user
      return if current_user.tos_accepted?
      return if permitted_paths?

      redirect_to_tos
    end

    def terms_and_conditions_page
      @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: current_organization)
    end

    def permitted_paths?
      permitted_paths = [tos_path,
                         decidim.delete_account_path,
                         decidim.accept_tos_path,
                         decidim.data_portability_path,
                         decidim.export_data_portability_path,
                         decidim.download_file_data_portability_path]
      permitted_paths.include?(request.path)
    end

    def tos_path
      decidim.page_path terms_and_conditions_page
    end

    def redirect_to_tos
      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path
    end
  end
end
