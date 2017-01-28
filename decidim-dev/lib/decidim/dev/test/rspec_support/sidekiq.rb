RSpec.configure do |config|
  config.before(:each) do
    Rails.application.config.active_job.queue_adapter = :inline
  end
end
