# frozen_string_literal: true

require "spec_helper"

describe Decidim::CollaborativeTexts::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: collaborative_text_component.organization) }
  let(:context) do
    {
      current_component: collaborative_text_component,
      document:
    }
  end
  let(:collaborative_text_component) { create(:collaborative_text_component) }
  let(:document) { create(:collaborative_text_document, component: collaborative_text_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :collaborative_text }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not collaborative text document" do
    context "when subject is anything else" do
      let(:action) do
        { scope: :admin, action: :bar, subject: :foo }
      end

      it_behaves_like "permission is not set"
    end
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :collaborative_text }
    end

    it_behaves_like "permission is not set"
  end

  describe "collaborative text document creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :collaborative_text }
    end

    it { is_expected.to be true }
  end

  describe "collaborative text document update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :collaborative_text }
    end

    it { is_expected.to be true }
  end
end
