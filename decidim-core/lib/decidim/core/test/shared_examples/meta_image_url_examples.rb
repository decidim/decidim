# frozen_string_literal: true

require "spec_helper"

shared_examples "meta image url examples" do |expected_image_url|
  def meta_image_url
    find('meta[property="og:image"]', visible: false)[:content]
  rescue Capybara::ElementNotFound
    nil
  end

  def visit_resource
    visit resource_locator(resource).path
  end

  it "correctly resolves meta image URL" do
    visit_resource
    expect(meta_image_url).to include(expected_image_url)
  end
end
