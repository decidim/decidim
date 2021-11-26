# frozen_string_literal: true

module Decidim
  #
  # Decorator for notifications.
  #
  class NotificationPresenter < SimpleDelegator
    include ActionView::Helpers::DateHelper

    def created_at_in_words
      if created_at.between?(1.month.ago, Time.current)
        time_ago_in_words(created_at)
      else
        format = created_at.year == Time.current.year ? :ddmm : :ddmmyyyy
        I18n.l(created_at, format: format)
      end
    end
  end
end
