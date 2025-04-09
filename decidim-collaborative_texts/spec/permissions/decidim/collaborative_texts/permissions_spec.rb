# frozen_string_literal: true

require "spec_helper"

describe Decidim::CollaborativeTexts::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: collaborative_text_component.organization) }
  let(:context) do
    {
      current_component: collaborative_text_component
    }
  end
  let(:collaborative_text_component) { create(:collaborative_text_component) }
  let(:document) { create(:collaborative_text_document, component: collaborative_text_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :document }
    end

    it_behaves_like "delegates permissions to", Decidim::CollaborativeTexts::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :document }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a collaborative text document" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end
end
