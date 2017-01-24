# frozen_string_literal: true
require "nokogiri"

RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end

# A set of helpers meant to make your life easier when testing
# emails, especially given the fact that ActionMailer's API can
# be a bit inconsistent.
module MailerHelpers
  def emails
    ActionMailer::Base.deliveries
  end

  def last_email
    emails.last
  end

  def last_email_body
    (last_email.try(:html_part).try(:body) || last_email.body).encoded
  end

  def last_email_link
    Nokogiri::HTML(last_email_body).css("table.content a").last["href"]
  end
end

RSpec.configure do |config|
  config.include MailerHelpers
end

RSpec.configure do |config|
  config.before :example, perform_enqueued: true do
    @old_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
    @old_perform_enqueued_at_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end

  config.after :example, perform_enqueued: true do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = @old_perform_enqueued_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = @old_perform_enqueued_at_jobs
  end
end
