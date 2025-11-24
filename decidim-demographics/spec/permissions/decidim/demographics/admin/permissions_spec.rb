# frozen_string_literal: true

require "spec_helper"

describe Decidim::Demographics::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:context) { {} }
  let(:action_name) { :foo }
  let(:action_subject) { :bar }
  let(:user) { create(:user) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  context "when user is not present" do
    let(:user) { nil }

    it_behaves_like "permission is not set"
  end

  describe "user demographics settings" do
    let(:action_subject) { :demographics }

    it_behaves_like "permission is not set"

    context "when user is not admin" do
      let(:action_name) { :update }

      it { is_expected.to be false }
    end

    context "when updating" do
      let(:action_name) { :update }

      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end
  end
end
