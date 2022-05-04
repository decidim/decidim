# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:voting) { create :voting, organization: organization }
  let(:context) { { voting: voting } }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when the action is for the admin part" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it_behaves_like "delegates permissions to", Decidim::Votings::Admin::Permissions
  end

  context "when the action is for the public part" do
    let(:action_name) { :read }
    let(:action) do
      { scope: :public, action: action_name, subject: action_subject }
    end

    context "when reading a consultation" do
      let(:action_subject) { :voting }

      context "when the consultation is published" do
        let(:voting) { create :voting, :published, organization: organization }

        it { is_expected.to be true }
      end
    end
  end
end
