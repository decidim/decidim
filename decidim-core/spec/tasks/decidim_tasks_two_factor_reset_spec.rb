# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:two_factor:reset", type: :task do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:authenticator) { create(:totp_authenticator, :confirmed, user:) }

  before do
    ENV["EMAIL"] = user.email
    ENV["HOST"] = organization.host
  end

  after do
    ENV.delete("EMAIL")
    ENV.delete("HOST")
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "removes the second factors of the given account" do
    task.execute

    expect(Decidim::TwoFactor::Authenticator.where(user:)).to be_empty
    expect($stdout.string).to include("Second factors removed")
  end

  it "leaves the account with the same email in another organization untouched" do
    namesake = create(:totp_authenticator, :confirmed, user: create(:user, :confirmed, email: user.email))

    task.execute

    expect(Decidim::TwoFactor::Authenticator.where(id: namesake.id)).to be_present
    expect(Decidim::TwoFactor::Authenticator.where(user:)).to be_empty
  end

  context "when the host matches no organization" do
    before { ENV["HOST"] = "unknown.example.org" }

    it "aborts" do
      expect { task.execute }.to raise_error(SystemExit)
    end
  end

  context "when the email matches no account of the organization" do
    before { ENV["EMAIL"] = "nobody@example.org" }

    it "aborts" do
      expect { task.execute }.to raise_error(SystemExit)
    end
  end

  context "when the account has no second factor" do
    before { ENV["EMAIL"] = create(:user, :confirmed, organization:).email }

    it "aborts" do
      expect { task.execute }.to raise_error(SystemExit)
    end
  end
end
