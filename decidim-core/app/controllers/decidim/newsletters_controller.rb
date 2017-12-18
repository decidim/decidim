# frozen_string_literal: true

module Decidim
  # The controller to show the newsletter on the website.
  class NewslettersController < Decidim::ApplicationController
    skip_authorization_check

    layout "decidim/mailer", only: [:show]
    helper Decidim::SanitizeHelper
    include Decidim::NewslettersHelper

    helper_method :newsletter

    def show
      @user = current_user
      @organization = current_organization

      if newsletter.sent?
        @body = parse_interpolations(newsletter.body[I18n.locale.to_s], @user, newsletter.id)
      else
        redirect_to decidim.root_url(host: @organization.host)
      end
    end

    def unsubscribe
      decrypted_string = sent_at_decrypted(params[:u])
      user = User.find_by(id: decrypted_string.split("-").first)
      sent_at_time = Time.zone.at(decrypted_string.split("-").second.to_i)

      if sent_at_time > (Time.current - 15.days) && user.newsletter_notifications
        UnsubscribeSettings.call(user) do
          on(:ok) do
            flash.now[:notice] = t("newsletters.unsubscribe.success", scope: "decidim")
          end

          on(:invalid) do
            flash.now[:alert] = t("newsletters.unsubscribe.error", scope: "decidim")
            render action: :show
          end
        end
      else
        redirect_to decidim.notifications_settings_path
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
