# frozen_string_literal: true

require "spec_helper"

describe ActiveStorage do
  it "active storage has .webp in content types" do
    expect(Rails.application.config.active_storage[:variable_content_types]).to include("image/webp")
  end
end
