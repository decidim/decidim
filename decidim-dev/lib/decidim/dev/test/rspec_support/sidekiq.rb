RSpec.configure do |config|
  config.before(:each) do
    config.active_job.queue_adapter = :inline
  end
end
