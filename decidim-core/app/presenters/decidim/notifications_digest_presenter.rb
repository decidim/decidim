# frozen_string_literal: true

module Decidim
  #
  # Decorator for events in mail digest
  #
  class NotificationsDigestPresenter < SimpleDelegator
    def subject
      I18n.t("decidim.notifications_digest_mailer.subject")
    end

    def header
      I18n.t("decidim.notifications_digest_mailer.header.#{frequency}")
    end

    def formated_date(date)
      I18n.l(date, format: :long)
    end

    def greeting
      I18n.t("decidim.notifications_digest_mailer.hello", name: name)
    end

    def intro
      I18n.t("decidim.notifications_digest_mailer.intro.#{frequency}")
    end

    def outro
      I18n.t("decidim.notifications_digest_mailer.outro")
    end

    def see_more
      I18n.t("decidim.notifications_digest_mailer.see_more")
    end

    private

    def frequency
      notifications_sending_frequency || "daily"
    end
  end
end
