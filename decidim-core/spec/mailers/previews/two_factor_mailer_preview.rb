# frozen_string_literal: true

module Decidim
  class TwoFactorMailerPreview < ActionMailer::Preview
    def factors_reset
      TwoFactorMailer.factors_reset(User.first)
    end
  end
end
