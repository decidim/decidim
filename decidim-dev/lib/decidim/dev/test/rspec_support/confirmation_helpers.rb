# frozen_string_literal: true

# Helpers that get automatically included in component specs.
module ConfirmationHelpers
  # Overrides the Capybara default accept_confirm because we have replaced the
  # system's own confirmation modal with foundation based modal.
  #
  # See:
  # https://github.com/teamcapybara/capybara/blob/44621209496fe4dd352709799a0061a80d97d562/lib/capybara/session.rb#L647
  def accept_confirm(_text = nil, **_options)
    yield if block_given?

    # The test can already be "within", so find the body using xpath
    message = nil
    body = find(:xpath, "/html/body")
    within(body.find(".confirm-reveal")) do
      message = find(".confirm-modal-content").text
      find("a.button[data-confirm-ok]").click
    end

    message
  end

  # Overrides the Capybara default dismiss_confirm because we have replaced the
  # system's own confirmation modal with foundation based modal.
  #
  # See:
  # https://github.com/teamcapybara/capybara/blob/44621209496fe4dd352709799a0061a80d97d562/lib/capybara/session.rb#L657
  def dismiss_confirm(_text = nil, **_options)
    yield if block_given?

    # The test can already be "within", so find the body using xpath
    message = nil
    body = find(:xpath, "/html/body")
    within(body.find(".confirm-reveal")) do
      message = find(".confirm-modal-content").text
      find("a.button[data-confirm-cancel]").click
    end

    message
  end

  # Used to accept the "onbeforeunload" event's normal browser confirm modal
  # as this cannot be overridden. Original confirm dismiss implementation in
  # Capybara.
  def accept_page_unload(text = nil, **options, &)
    page.send(:accept_modal, :confirm, text, options, &)
  end

  # Used to dismiss the "onbeforeunload" event's normal browser confirm modal
  # as this cannot be overridden. Original confirm dismiss implementation in
  # Capybara.
  def dismiss_page_unload(text = nil, **options, &)
    page.send(:dismiss_modal, :confirm, text, options, &)
  end
end

RSpec.configure do |config|
  config.include ConfirmationHelpers, type: :system
end
