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
      return true unless request.format.html?
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
                         decidim.download_your_data_path,
                         decidim.export_download_your_data_path,
                         decidim.download_file_download_your_data_path]
      # ensure that path with or without query string pass
      permitted_paths.find { |el| el.split("?").first == request.path }
    end

    def tos_path
      decidim.page_path terms_and_conditions_page
    end

    def redirect_to_tos
      # Store the location where the user needs to be redirected to after the
      # TOS is agreed.
      store_location_for(
        current_user,
        stored_location_for(current_user) || request.path
      )

      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path
    end
  end
end
