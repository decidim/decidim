# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::InitiativeUserAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, :created, organization: organization) }

  context "when regular user" do
    let(:user) { create(:user, organization: organization) }

    it "do not lets user show/edit/preview/update initiative" do
      expect(subject).not_to be_able_to(:preview, initiative)
      expect(subject).not_to be_able_to(:show, initiative)
      expect(subject).not_to be_able_to(:edit, initiative)
      expect(subject).not_to be_able_to(:update, initiative)
    end

    it "do not lets user access the dashboard" do
      expect(subject).not_to be_able_to(:read, :admin_dashboard)
    end

    it "do not lets user access to initiative list" do
      expect(subject).not_to be_able_to(:list, Decidim::Initiative)
    end

    it "can not send initiative to technical  validation" do
      expect(subject).not_to be_able_to(:send_to_technical_validation, initiative)
    end
  end

  context "when initiative author" do
    let(:user) { initiative.author }

    it "lets user show/edit/preview/update initiative" do
      expect(subject).to be_able_to(:preview, initiative)
      expect(subject).to be_able_to(:show, initiative)
      expect(subject).to be_able_to(:edit, initiative)
      expect(subject).to be_able_to(:update, initiative)
    end

    it "lets user access the dashboard" do
      expect(subject).to be_able_to(:read, :admin_dashboard)
    end

    it "lets user access to initiative list" do
      expect(subject).to be_able_to(:index, Decidim::Initiative)
    end

    it "lets user send initiative to technical  validation" do
      expect(subject).to be_able_to(:send_to_technical_validation, initiative)
    end

    it "cannot update initiatives in validation phase" do
      expect(subject).not_to be_able_to(:update, create(:initiative, :validating, organization: organization, author: user))
    end
  end

  context "when committee member" do
    let(:user) { initiative.committee_members.approved.first.user }

    it "lets user show/edit/preview/update initiative" do
      expect(subject).to be_able_to(:preview, initiative)
      expect(subject).to be_able_to(:show, initiative)
      expect(subject).to be_able_to(:edit, initiative)
      expect(subject).to be_able_to(:update, initiative)
    end

    it "lets user access the dashboard" do
      expect(subject).to be_able_to(:read, :admin_dashboard)
    end

    it "lets user access to initiative list" do
      expect(subject).to be_able_to(:index, Decidim::Initiative)
    end

    it "lets user send initiative to technical  validation" do
      expect(subject).to be_able_to(:send_to_technical_validation, initiative)
    end
  end
end
