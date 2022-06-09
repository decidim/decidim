# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: survey_component.organization }
  let(:context) do
    {
      current_component: survey_component
    }
  end
  let(:survey_component) { create :surveys_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :questionnaire }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a survey" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :questionnaire }
    end

    it_behaves_like "permission is not set"
  end

  context "when exporting answers for a survey" do
    let(:action) do
      { scope: :admin, action: :export_answers, subject: :questionnaire }
    end

    it { is_expected.to be true }
  end

  context "when updating a survey" do
    let(:action) do
      { scope: :admin, action: :update, subject: :questionnaire }
    end

    it { is_expected.to be true }
  end

  context "when indexing a survey's answers" do
    let(:action) do
      { scope: :admin, action: :index, subject: :questionnaire_answers }
    end

    it { is_expected.to be true }
  end

  context "when showing a participant's survey answers" do
    let(:action) do
      { scope: :admin, action: :show, subject: :questionnaire_answers }
    end

    it { is_expected.to be true }
  end

  context "when exporting a participant's survey answers" do
    let(:action) do
      { scope: :admin, action: :export_response, subject: :questionnaire_answers }
    end

    it { is_expected.to be true }
  end
end
