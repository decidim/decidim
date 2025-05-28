# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: elections_component.organization) }
  let(:context) do
    {
      current_component: elections_component,
      election:
    }
  end
  let(:elections_component) { create(:elections_component) }
  let(:election) { create(:election, component: elections_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :debate }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not debate" do
    context "when subject is anything else" do
      let(:action) do
        { scope: :admin, action: :bar, subject: :foo }
      end

      it_behaves_like "permission is not set"
    end
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :debate }
    end

    it_behaves_like "permission is not set"
  end

  describe "create permission" do
    let(:action) { { scope: :admin, action: :create, subject: :election } }

    it { is_expected.to be true }
  end

  describe "read permission" do
    let(:action) { { scope: :admin, action: :read, subject: :election } }

    it { is_expected.to be true }
  end

  describe "update permission with election present" do
    let(:action) { { scope: :admin, action: :update, subject: :election } }

    it { is_expected.to be true }
  end

  describe "update permission without election" do
    let(:election) { nil }
    let(:action) { { scope: :admin, action: :update, subject: :election } }

    it { is_expected.to be false }
  end
end
