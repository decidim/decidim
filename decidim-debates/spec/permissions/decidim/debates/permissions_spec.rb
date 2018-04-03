# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: debates_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: debates_component,
      current_settings: current_settings,
      debate: debate,
      component_settings: nil
    }
  end
  let(:debates_component) { create :debates_component }
  let(:debate) { create :debate, component: debates_component }
  let(:current_settings) do
    double(settings.merge(extra_settings))
  end
  let(:settings) do
    {
      creation_enabled?: false
    }
  end
  let(:extra_settings) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:new)
      .and_return(space_permissions)
  end

  context "when space does not allow the user to perform the action" do
    let(:space_allows) { false }
    let(:action) do
      { scope: :public, action: :foo, subject: :debate }
    end

    it { is_expected.to eq false }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :debate }
    end
    let(:space_allows) { true }

    it "delegates the check to the admin permissions class" do
      admin_permissions = instance_double(Decidim::Debates::Admin::Permissions, allowed?: true)
      allow(Decidim::Debates::Admin::Permissions)
        .to receive(:new)
        .with(user, permission_action, context)
        .and_return admin_permissions

      expect(admin_permissions)
        .to receive(:allowed?)

      subject
    end
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :debate }
    end

    it { is_expected.to eq false }
  end

  context "when subject is not a debate" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it { is_expected.to eq false }
  end

  context "when creating a debate" do
    let(:action) do
      { scope: :public, action: :create, subject: :debate }
    end

    context "when creation is disabled" do
      let(:extra_settings) { { creation_enabled?: false } }

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) { { creation_enabled?: true } }

      it { is_expected.to eq true }
    end
  end

  context "when reporting a debate" do
    let(:action) do
      { scope: :public, action: :report, subject: :debate }
    end

    it { is_expected.to eq true }
  end
end
