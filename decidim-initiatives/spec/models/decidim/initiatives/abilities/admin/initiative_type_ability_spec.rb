# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::InitiativeTypeAbility do
  subject { described_class.new(user, {}) }

  describe "regular users" do
    let(:user) { build(:user) }

    it "can not manage  initiative types" do
      expect(subject).not_to be_able_to(:manage, Decidim::InitiativesType)
    end

    it "can not manage initiative type scopes" do
      expect(subject).not_to be_able_to(:manage, Decidim::InitiativesTypeScope)
    end
  end

  describe "Administrators" do
    let(:user) { build(:user, :admin) }
    let(:initiative) { create(:initiative, organization: user.organization) }

    it "lets user manage initiative types" do
      expect(subject).to be_able_to(:manage, Decidim::InitiativesType)
    end

    it "lets user manage initiative type scopes" do
      expect(subject).to be_able_to(:manage, Decidim::InitiativesTypeScope)
    end

    it "can not destroy initiative types associated with initiatives" do
      expect(subject).not_to be_able_to(:destroy, initiative.type)
    end

    it "can not destroy initiative type scopes with initiatives" do
      expect(subject).not_to be_able_to(:destroy, initiative.scoped_type)
    end
  end
end
