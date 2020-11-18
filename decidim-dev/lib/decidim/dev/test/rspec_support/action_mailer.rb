# frozen_string_literal: true

require "nokogiri"

RSpec.configure do |config|
  config.before { clear_emails }
end

# A set of helpers meant to make your life easier when testing
# emails, especially given the fact that ActionMailer's API can
# be a bit inconsistent.
module MailerHelpers
  def emails
    ActionMailer::Base.deliveries
  end

  def clear_emails
    ActionMailer::Base.deliveries.clear
  end

  def last_email
    emails.last
  end

  def last_email_body
    email_body(last_email)
  end

  def email_body(email)
    (email.try(:html_part).try(:body) || email.try(:body))&.encoded
  end

  def last_email_link
    Nokogiri::HTML(last_email_body).css("table.content a").last["href"]
  end

  def last_email_first_link
    Nokogiri::HTML(last_email_body).css("table.content a").first["href"]
  end
end

RSpec.configure do |config|
  config.include MailerHelpers
end
