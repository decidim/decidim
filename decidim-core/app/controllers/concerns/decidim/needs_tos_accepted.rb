# frozen_string_literal: true

module Decidim
  # Shared behaviour for signed_in users that require the latest TOS accepted
  module NeedsTosAccepted
    extend ActiveSupport::Concern

    included do
      before_action :tos_accepted_by_user
      helper_method :terms_of_service_page, :terms_of_service_summary_content_blocks
    end

    private

    def tos_accepted_by_user
      return true unless request.format.html?
      return true unless current_user
      return if current_user.tos_accepted? || current_user.ephemeral?
      return if permitted_paths?

      redirect_to_tos
    end

    def terms_of_service_page
      @terms_of_service_page ||= Decidim::StaticPage.find_by(slug: "terms-of-service", organization: current_organization)
    end

    def terms_of_service_summary_content_blocks
      @terms_of_service_summary_content_blocks ||= Decidim::ContentBlock.published
                                                                        .for_scope(:static_page, organization: current_organization)
                                                                        .where(scoped_resource_id: terms_of_service_page.id)
                                                                        .reject { |content_block| content_block.manifest.nil? || content_block.manifest.name != :summary }
    end

    def permitted_paths?
      return true if request.path.starts_with?(decidim.download_your_data_path)

      permitted_paths = [tos_path,
                         decidim.delete_account_path,
                         decidim.accept_tos_path]
      # ensure that path with or without query string pass
      permitted_paths.find { |el| el.split("?").first == request.path }
    end

    def tos_path
      decidim.page_path terms_of_service_page, locale: current_locale
    end

    def redirect_to_tos
      # Store the location where the user needs to be redirected to after the
      # TOS is agreed.
      store_location_for(
        current_user,
        stored_location_for(current_user) || request.path
      )

      flash[:notice] = flash[:notice] if flash[:notice]
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_of_service")
      redirect_to tos_path
    end
  end
end
