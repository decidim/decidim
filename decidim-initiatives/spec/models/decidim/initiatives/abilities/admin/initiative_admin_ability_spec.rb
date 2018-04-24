# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::InitiativeAdminAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, organization: organization) }
  let(:initiative) { create(:initiative, :created, organization: organization) }

  it "lets the user manage initiatives" do
    expect(subject).to be_able_to(:manage, Decidim::Initiative)
  end

  it "lets the user preview created initiatives" do
    expect(subject).to be_able_to(:preview, Decidim::Initiative)
  end

  it "lets the user to send initiatives to technical validation" do
    expect(subject).to be_able_to(:send_to_technical_validation, Decidim::Initiative)
  end

  it "lets the user preview validating initiatives" do
    expect(subject).to be_able_to(:preview, create(:initiative, :validating))
  end

  it "lets the user discard initiatives" do
    expect(subject).to be_able_to(:discard, create(:initiative, :validating))
    expect(subject).not_to be_able_to(:discard, create(:initiative))
  end

  it "lets the user publish initiatives" do
    expect(subject).to be_able_to(:publish, create(:initiative, :validating))
    expect(subject).not_to be_able_to(:publish, create(:initiative))
  end

  it "lets the user unpublish initiatives" do
    expect(subject).to be_able_to(:unpublish, create(:initiative))
    expect(subject).not_to be_able_to(:unpublish, create(:initiative, :validating))
  end

  it "lets the user to export votes" do
    expect(subject).not_to be_able_to(:export_votes, create(:initiative, signature_type: "online"))
    expect(subject).to be_able_to(:export_votes, create(:initiative, signature_type: "any"))
    expect(subject).to be_able_to(:export_votes, create(:initiative, signature_type: "offline"))
  end

  it "lets the user accept initiatives" do
    expect(subject).to be_able_to(:accept, create(:initiative, :acceptable))
    expect(subject).not_to be_able_to(:accept, create(:initiative, :rejectable))
  end

  it "lets the user reject initiatives" do
    expect(subject).not_to be_able_to(:reject, create(:initiative, :acceptable))
    expect(subject).to be_able_to(:reject, create(:initiative, :rejectable))
  end
end
