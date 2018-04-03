# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: debates_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: debates_component,
      debate: debate
    }
  end
  let(:debates_component) { create :debates_component }
  let(:debate) { create :debate, component: debates_component }
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
      { scope: :admin, action: :foo, subject: :debate }
    end

    it { is_expected.to eq false }
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :debate }
    end

    it { is_expected.to eq false }
  end

  context "when subject is not debate" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :foo }
    end

    it { is_expected.to eq false }
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :debate }
    end

    it { is_expected.to eq false }
  end

  describe "debate creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :debate }
    end

    it { is_expected.to eq true }
  end

  describe "debate update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :debate }
    end

    context "when the debate is official" do
      it { is_expected.to eq true }
    end

    context "when debate is not official" do
      let(:debate) { create :debate, author: user, component: debates_component }

      it { is_expected.to eq false }
    end
  end

  describe "debate delete" do
    let(:action) do
      { scope: :admin, action: :delete, subject: :debate }
    end

    context "when the debate is official" do
      it { is_expected.to eq true }
    end

    context "when debate is not official" do
      let(:debate) { create :debate, author: user, component: debates_component }

      it { is_expected.to eq false }
    end
  end
end
