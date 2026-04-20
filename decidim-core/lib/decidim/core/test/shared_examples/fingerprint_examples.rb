# frozen_string_literal: true

shared_examples "fingerprint" do
  include_context("with a component")

  it "shows a fingerprint" do
    visit(resource_locator(fingerprintable).path)
    click_on("see other versions")
    click_on("Check fingerprint")

    within ".fingerprint-modal" do
      expect(page).to(have_content(fingerprintable.fingerprint.value))
      expect(page).to(have_content(fingerprintable.fingerprint.source))
    end
  end
end

shared_examples "consistent fingerprint" do
  include_context("with a component")

  it "shows the fingerprint source with correct spacing" do
    visit(resource_locator(fingerprintable).path)
    click_on("see other versions")
    click_on("Check fingerprint")

    within ".fingerprint-modal" do
      expect(page).to(have_content(fingerprintable.body.to_json))
    end
  end
end
