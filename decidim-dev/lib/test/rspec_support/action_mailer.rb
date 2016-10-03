# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end

module MailerHelpers
  def emails
    ActionMailer::Base.deliveries
  end

  def last_email
    emails.last
  end
end

RSpec.configure do |config|
  config.include MailerHelpers, type: :mailer
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
