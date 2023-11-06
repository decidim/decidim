# frozen_string_literal: true

shared_examples "fingerprint" do
  include_context("with a component")

  it "shows a fingerprint" do
    visit(resource_locator(fingerprintable).path)
    click_button("Check fingerprint")

    within ".fingerprint-modal" do
      expect(page).to(have_content(fingerprintable.fingerprint.value))
      expect(page).to(have_content(fingerprintable.fingerprint.source))
    end
  end
end
