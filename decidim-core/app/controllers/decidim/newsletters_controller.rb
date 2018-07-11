# frozen_string_literal: true

module Decidim
  # The controller to show the newsletter on the website.
  class NewslettersController < Decidim::ApplicationController
    layout "decidim/mailer", only: [:show]
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    helper_method :newsletter

    def show
      @user = current_user
      @organization = current_organization

      raise ActionController::RoutingError, "Not Found" unless newsletter.sent?

      @encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(@user.id, newsletter.sent_at) if @user.present?
      @body = parse_interpolations(newsletter.body[I18n.locale.to_s], @user, newsletter.id)
    end

    def unsubscribe
      encryptor = Decidim::NewsletterEncryptor

      decrypted_string = encryptor.sent_at_decrypted(params[:u])
      user = User.find_by(decidim_organization_id: current_organization.id, id: decrypted_string.split("-").first)
      sent_at_time = Time.zone.at(decrypted_string.split("-").second.to_i)

      if sent_at_time > (Time.current - 15.days)
        UnsubscribeSettings.call(user) do
          on(:ok) do
            flash.now[:notice] = t("newsletters.unsubscribe.success", scope: "decidim")
          end

          on(:invalid) do
            flash.now[:alert] = t("newsletters.unsubscribe.error", scope: "decidim")
            render action: :unsubscribe
          end
        end
      else
        flash.now[:alert] = t("newsletters.unsubscribe.token_error", scope: "decidim")
        render action: :unsubscribe
      end
    end

    def newsletter
      @newsletter ||= collection.find(params[:id])
    end

    private

    def collection
      Newsletter.where(organization: current_organization)
    end
  end
end
