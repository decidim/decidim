# frozen_string_literal: true

require "spec_helper"

describe Decidim::Demographics::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:context) { {} }
  let(:action_name) { :foo }
  let(:action_subject) { :bar }
  let(:user) { create(:user) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:collect_data) { false }

  let(:action) do
    { scope: :public, action: action_name, subject: action_subject }
  end

  context "when user is not present" do
    let(:user) { nil }

    it_behaves_like "permission is not set"
  end

  describe "user demographics settings" do
    let!(:demographic) { create(:demographic, organization: user.reload.organization, collect_data:) }
    let(:action_name) { :respond }
    let(:action_subject) { :demographics }

    context "when collecting data is possible" do
      let(:collect_data) { true }

      it { is_expected.to be true }
    end

    context "when collecting data is disabled" do
      it { is_expected.to be false }
    end
  end
end
