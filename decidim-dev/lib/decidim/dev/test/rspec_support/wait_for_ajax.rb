# frozen_string_literal: true

module WaitForAjax
  # We should show the user that there's been an ajax call so the spinner should always be used.
  # Not using a spinner should have a justified reason.
  def wait_for_ajax(with_spinner: true)
    (Capybara.default_max_wait_time * 2).times do
      sleep(0.5)
      expect(ajax_finished?(with_spinner)).to be_truthy
      break
    rescue StandardError
      # ignore and loop again if ajax has not finished
      nil
    end
    expect(ajax_finished?(with_spinner)).to be_truthy
  end

  def ajax_finished?(with_spinner)
    finished_all_ajax_requests? && (with_spinner ? spinner_hidden? : true)
  end

  def finished_all_ajax_requests?
    page.evaluate_script("jQuery.active").zero?
  end

  def spinner_hidden?
    assert_selector(".spinner-container.hide", visible: :hidden)
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :system
end
