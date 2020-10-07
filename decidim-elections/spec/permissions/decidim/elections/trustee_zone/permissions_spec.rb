# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: elections_component.organization }
  let(:context) do
    {
      current_component: elections_component
    }
  end
  let(:elections_component) { create :elections_component }
  let!(:trustee) { create(:trustee, user: user) }
  let(:permission_action) { Decidim::PermissionAction.new(action) }


  shared_examples "not allowed when the user is not a trustee" do
    context "when the user is not a trustee" do
      let!(:trustee) { create(:trustee) }

      it { is_expected.to be_falsey }
    end
  end

  context "when scope is not trustee zone" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a trustee" do
    let(:action) do
      { scope: :trustee_zone, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :trustee_zone, action: :bar, subject: :trustee }
    end

    it_behaves_like "permission is not set"
  end

  describe "view trustee" do
    let(:action) do
      { scope: :trustee_zone, action: :view, subject: :trustee }
    end

    it { is_expected.to eq true }

    it_behaves_like "not allowed when the user is not a trustee"
  end
end
