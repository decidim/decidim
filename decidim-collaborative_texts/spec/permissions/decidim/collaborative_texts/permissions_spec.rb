# frozen_string_literal: true

require "spec_helper"

describe Decidim::CollaborativeTexts::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: collaborative_text_component.organization) }
  let(:context) do
    {
      current_component: collaborative_text_component,
      document: document
    }
  end
  let(:collaborative_text_component) { create(:collaborative_text_component) }
  let(:document) { create(:collaborative_text_document, component: collaborative_text_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :collaborative_text }
    end

    it_behaves_like "delegates permissions to", Decidim::CollaborativeTexts::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :collaborative_text }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a collaborative text document" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is suggest" do
    let(:action) do
      { scope: :public, action: :suggest, subject: :collaborative_text }
    end

    context "when user is logged in" do
      it { is_expected.to be true }
    end

    context "when user is not logged in" do
      let(:user) { nil }

      it_behaves_like "permission is not set"
    end
  end

  context "when action is rollout" do
    let(:action) do
      { scope: :public, action: :rollout, subject: :collaborative_text }
    end

    context "when user is logged in" do
      context "when user is an admin" do
        let(:user) { create(:user, :admin, organization: collaborative_text_component.organization) }

        it { is_expected.to be true }
      end

      context "when user is not an admin" do
        it_behaves_like "permission is not set"
      end

      context "when user is a participatory space admin" do
        let(:user) { create(:process_admin, participatory_process: collaborative_text_component.participatory_space) }

        it { is_expected.to be true }
      end
    end

    context "when user is not logged in" do
      let(:user) { nil }

      it_behaves_like "permission is not set"
    end
  end
end
