# frozen_string_literal: true

require "spec_helper"

describe Decidim::ReportUserPermissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { nil }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:action) do
    { scope: :public, action: :create, subject: :user_report }
  end

  it { expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError) }

  context "when a user exists" do
    let(:user) { build(:user) }

    it { is_expected.to be(true) }

    context "and the permission action and subject are not as expected" do
      let(:action) do
        { scope: :public, action: :foo, subject: :bar }
      end

      it { expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError) }
    end
  end
end
