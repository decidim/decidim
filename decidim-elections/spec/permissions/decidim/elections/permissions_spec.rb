# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: component.organization) }
  let(:component) { create(:elections_component) }
  let(:election) { create(:election, component:) }
  let(:context) do
    {
      current_component: component,
      election:
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :election }
    end

    it_behaves_like "delegates permissions to", Decidim::Elections::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a election" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when accessing an election" do
    let(:action) do
      { scope: :public, action: :read, subject: :election }
    end

    it_behaves_like "permission is not set"
    context "when election is published" do
      let(:election) { create(:election, :published, component:) }

      it { is_expected.to be true }
    end
  end

  context "when creating a vote" do
    let(:action) do
      { scope: :public, action: :create, subject: :vote }
    end

    it_behaves_like "permission is not set"

    context "when election is published" do
      let(:election) { create(:election, :published, component:) }

      it_behaves_like "permission is not set"
    end

    context "when election is ongoing and published" do
      let(:election) { create(:election, :published, :ongoing, component:) }

      it { is_expected.to be true }
    end
  end
end
