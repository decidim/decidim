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
      expect(page).to have_css('a[title="Share to QR"]')
      expect(page).to have_css(".share-modal__input")
    end
  end
end

shared_examples "a social share via QR code" do
  let(:title) { resource.presenter.title }
  let(:parameterized_title) { CGI.escapeHTML(title) }
  let!(:card_image) { nil }

  it "properly generates a resolvable url" do
    visit_resource
    click_on "Share"

    execute_script("window.location.href = document.getElementById('urlShareLink').value")

    expect(page).to have_current_path(resource_locator(resource).path, ignore_query: true)
  end

  context "when the url is malformed" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim.qr_path(resource: "Missing") }
    end
  end

  it "has the QR code" do
    visit_resource
    click_on "Share"
    click_on "Share to QR"

    expect(page).to have_content("QR Code")
    within "#QRCodeDialog" do
      expect(page).to have_css(%(img[alt="QR Code"]))
      expect(page).to have_link("Print poster")
      expect(page).to have_content(title)
      expect(page).to have_link("Download")
    end
  end

  it "downloads the QR code", download: true do
    visit_resource
    click_on "Share"
    click_on "Share to QR"
    click_on "Download"

    wait_for_download

    expect(downloads.length).to eq(1)
    expect(download_path).to match(/.*\.png/)
  end

  it "displays the QR code page" do
    visit_resource
    click_on "Share"
    click_on "Share to QR"
    click_on "Print poster"
    expect(page).to have_content("Scan the QR code")
    expect(page).to have_css(%(img[alt="QR Code for #{parameterized_title}"]))

    expect(page).to have_css(%(img[src*="#{card_image}"])) unless card_image.nil?
    expect(page).to have_content(title)

    expect(page).to have_content(translated(organization.name))
  end

  it "generates the same QR code" do
    visit_resource
    click_on "Share"
    click_on "Share to QR"

    image = "Avoid comparing empty strings"

    within "#QRCodeDialog" do
      image = find("img")[:src]
    end

    click_on "Print poster"
    new_image = find(%(img[alt="QR Code for #{parameterized_title}"]))[:src]

    expect(image).to eq(new_image)
  end
end
