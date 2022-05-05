# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: debates_component.organization }
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
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :debate }
    end

    it_behaves_like "delegates permissions to", Decidim::Debates::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :debate }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a debate" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a debate" do
    let(:action) do
      { scope: :public, action: :create, subject: :debate }
    end

    context "when creation is disabled" do
      let(:extra_settings) { { creation_enabled?: false } }

      it { is_expected.to be false }
    end

    context "when user is authorized" do
      let(:extra_settings) { { creation_enabled?: true } }

      it { is_expected.to be true }
    end
  end

  context "when editing a debate" do
    let(:action) do
      { scope: :public, action: :edit, subject: :debate }
    end

    context "when the user is the author" do
      let(:debate) { create :debate, author: user, component: debates_component }

      it { is_expected.to be true }
    end

    context "when the user is not the author" do
      it { is_expected.to be false }
    end
  end

  context "when reporting a debate" do
    let(:action) do
      { scope: :public, action: :report, subject: :debate }
    end

    it { is_expected.to be true }
  end

  context "when endorsing a debate" do
    let(:action) do
      { scope: :public, action: :endorse, subject: :debate }
    end

    it { is_expected.to be true }

    context "when the debate is closed" do
      let(:debate) { create :debate, :closed, component: debates_component }

      it { is_expected.to be false }
    end
  end
end
