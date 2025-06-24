# frozen_string_literal: true

require "spec_helper"

def visit_resource
  return visit resource if resource.is_a?(String)

  return visit decidim.root_path if resource.is_a?(Decidim::Organization)

  visit resource_locator(resource).path
end

shared_examples "a empty social share meta tag" do
  it "has no meta tag" do
    visit_resource
    expect(find('meta[property="og:image"]', visible: false)[:content]).to be_blank
  end
end

shared_examples "a social share meta tag" do |image|
  it "has meta tag for #{image}" do
    visit_resource
    expect(find('meta[property="og:image"]', visible: false)[:content]).to end_with(image)
  end
end

shared_examples "a social share widget" do
  it "has the social share button" do
    visit_resource

    expect(page).to have_css('button[data-dialog-open="socialShare"]')
  end

  it "lists all the expected social share providers" do
    visit_resource
    click_on "Share"

    within "#socialShare" do
      expect(page).to have_css('a[title="Share to X"]')
      expect(page).to have_css('a[title="Share to Facebook"]')
      expect(page).to have_css('a[title="Share to WhatsApp"]')
      expect(page).to have_css('a[title="Share to Telegram"]')
      expect(page).to have_css(".share-modal__input")
    end
  end
end
