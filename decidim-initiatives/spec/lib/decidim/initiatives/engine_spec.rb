# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Engine do
  it "loads engine mailer previews" do
    expect(ActionMailer::Preview.all).to include(Decidim::Initiatives::InitiativesMailerPreview)
  end
end
