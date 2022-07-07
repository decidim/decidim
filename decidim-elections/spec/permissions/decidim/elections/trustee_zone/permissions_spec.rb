# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: elections_component.organization }
  let(:context) do
    {
      current_component: elections_component,
      trustee: permission_trustee
    }
  end
  let(:elections_component) { create :elections_component }
  let(:trustee) { create(:trustee, user: user) }
  let(:election) do
    create(:election, :ready_for_setup, trustees_participatory_space: trustee_participatory_space)
  end
  let(:trustee_participatory_space) { create :trustees_participatory_space, trustee: trustee }
  let(:permission_trustee) { trustee }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "not allowed when the user is not a trustee" do
    context "when the user is not a trustee" do
      let!(:trustee) { create(:trustee) }

      it { is_expected.to be_falsey }
    end
  end

  shared_examples "not allowed when the given trustee is not the same than the user trustee" do
    context "when the trustee is not the same than the user trustee" do
      let(:permission_trustee) { create(:trustee) }

      it { is_expected.to be_falsey }
    end
  end

  shared_examples "not allowed when election is not attached to trustee" do
    context "when the election is not an election for the trustee" do
      let(:permission_trustee) { create(:trustee) }
      let(:permission_election) { create(:election, :ready_for_setup) }

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

    it { is_expected.to be true }

    it_behaves_like "not allowed when the user is not a trustee"
    it_behaves_like "not allowed when the given trustee is not the same than the user trustee"
  end

  describe "update trustee" do
    let(:action) do
      { scope: :trustee_zone, action: :update, subject: :trustee }
    end

    it { is_expected.to be true }

    it_behaves_like "not allowed when the user is not a trustee"
    it_behaves_like "not allowed when the given trustee is not the same than the user trustee"
  end

  describe "view election" do
    let(:action) do
      { scope: :trustee_zone, action: :view, subject: :election }
    end

    it { is_expected.to be true }

    it_behaves_like "not allowed when the user is not a trustee"
    it_behaves_like "not allowed when the given trustee is not the same than the user trustee"
  end

  describe "update election" do
    let(:action) do
      { scope: :trustee_zone, action: :update, subject: :election }
    end

    it { is_expected.to be true }

    it_behaves_like "not allowed when election is not attached to trustee"
    it_behaves_like "not allowed when the user is not a trustee"
    it_behaves_like "not allowed when the given trustee is not the same than the user trustee"
  end
end
