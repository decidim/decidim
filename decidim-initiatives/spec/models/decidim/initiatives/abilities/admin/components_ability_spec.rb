# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::ComponentsAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, :created, organization: organization) }

  context "when initiative authors" do
    let(:user) { initiative.author }

    it "can not manage components" do
      expect(subject).not_to be_able_to(:manage, Decidim::Component)
    end
  end

  context "when initiative committee members" do
    let(:user) { initiative.committee_members.approved.first.user }

    it "can not manage components" do
      expect(subject).not_to be_able_to(:manage, Decidim::Component)
    end
  end

  context "when regular users" do
    let(:user) { create(:user, organization: organization) }

    it "can not manage components" do
      expect(subject).not_to be_able_to(:manage, Decidim::Component)
    end
  end
end
