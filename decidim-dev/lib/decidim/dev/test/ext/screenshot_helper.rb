# frozen_string_literal: true

require "action_dispatch/system_testing/test_helpers/setup_and_teardown"

::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown.module_eval do
  def before_setup
    super
  end

  def after_teardown
    super
  end
end
