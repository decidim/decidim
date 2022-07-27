# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: debates_component.organization }
  let(:context) do
    {
      current_component: debates_component,
      debate:
    }
  end
  let(:debates_component) { create :debates_component }
  let(:debate) { create :debate, component: debates_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :debate }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not debate" do
    context "when subject is comments and action is export" do
      let(:action) do
        { scope: :admin, action: :export, subject: :comments }
      end

      it { is_expected.to be true }
    end

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

  describe "debate creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :debate }
    end

    it { is_expected.to be true }
  end

  describe "debate update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :debate }
    end

    context "when the debate is official" do
      it { is_expected.to be true }
    end

    context "when debate is not official" do
      let(:debate) { create :debate, author: user, component: debates_component }

      it { is_expected.to be false }
    end
  end

  describe "debate delete" do
    let(:action) do
      { scope: :admin, action: :delete, subject: :debate }
    end

    context "when the debate is official" do
      it { is_expected.to be true }
    end

    context "when debate is not official" do
      let(:debate) { create :debate, author: user, component: debates_component }

      it { is_expected.to be false }
    end
  end
end
