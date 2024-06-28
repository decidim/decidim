# frozen_string_literal: true

require "spec_helper"

def visit_resource
  return visit decidim.root_path if resource.is_a?(Decidim::Organization)

  visit resource_locator(resource).path
end

shared_examples "a empty social share meta tag" do
  it "has default meta tag" do
    visit_resource
    expect(find('meta[property="og:image"]', visible: false)[:content]).to be_blank
  end
end

shared_examples "a social share meta tag" do |image|
  it "has default meta tag" do
    visit_resource
    expect(find('meta[property="og:image"]', visible: false)[:content]).to end_with(image)
  end
end
