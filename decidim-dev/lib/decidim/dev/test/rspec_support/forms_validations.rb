# frozen_string_literal: true

module FormsValidationsHelpers
  MESSAGES = {
    text: "Please fill out this field.",
    select: "Please select an item in the list."
  }.freeze

  def expect_blank_field_validation_message(selector, opts = {})
    type = opts.fetch(:type, :text).to_sym
    expected_message = opts.fetch(:message, MESSAGES[type])
    message = page.find(selector).native.attribute("validationMessage")

    expect(message).to eq expected_message
  end
end

RSpec.configure do |config|
  config.include FormsValidationsHelpers, type: :system
end
