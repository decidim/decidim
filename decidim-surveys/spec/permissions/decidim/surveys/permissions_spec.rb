# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: survey_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: survey_component
    }
  end
  let(:survey_component) { create :surveys_component }
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
      { scope: :public, action: :foo, subject: :survey }
    end

    it { is_expected.to eq false }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end
    let(:space_allows) { true }

    it "delegates the check to the admin permissions class" do
      admin_permissions = instance_double(Decidim::Surveys::Admin::Permissions, allowed?: true)
      allow(Decidim::Surveys::Admin::Permissions)
        .to receive(:new)
        .with(user, permission_action, context)
        .and_return admin_permissions

      expect(admin_permissions)
        .to receive(:allowed?)

      subject
    end
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :survey }
    end

    it { is_expected.to eq false }
  end

  context "when subject is not a survey" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it { is_expected.to eq false }
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foo, subject: :survey }
    end

    it { is_expected.to eq false }
  end

  context "when answering a survey" do
    let(:action) do
      { scope: :public, action: :answer, subject: :survey }
    end

    context "when user is authorized" do
      it { is_expected.to eq true }
    end
  end
end
