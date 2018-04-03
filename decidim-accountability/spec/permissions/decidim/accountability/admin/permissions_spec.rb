# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { build :user }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: accountability_component,
    }
  end
  let(:accountability_component) { create :accountability_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:new)
      .and_return(space_permissions)
  end

  context "in any other condition" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :foo }
    end

    it { is_expected.to eq false }
  end
end
