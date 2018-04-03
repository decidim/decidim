# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { build :user }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: create(:budget_component)
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:new)
      .and_return(space_permissions)
  end

  describe "projects" do
    let(:action) do
      { scope: :admin, action: :create, subject: :project }
    end

    context "when the space allows it" do
      it { is_expected.to eq true }
    end

    context "when the space does not allow it" do
      let(:space_allows) { false }

      it { is_expected.to eq false }
    end
  end
end
