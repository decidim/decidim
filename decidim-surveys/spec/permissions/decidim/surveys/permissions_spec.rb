# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: survey_component.organization) }
  let(:context) do
    {
      current_component: survey_component
    }
  end
  let(:survey_component) { create(:surveys_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end

    it_behaves_like "delegates permissions to", Decidim::Surveys::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :questionnaire }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a survey" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foo, subject: :questionnaire }
    end

    it_behaves_like "permission is not set"
  end

  context "when responding a survey" do
    let(:action) do
      { scope: :public, action: :respond, subject: :questionnaire }
    end

    context "when user is authorized" do
      it { is_expected.to be true }
    end
  end
end
