# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blog::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: blog_component.organization }
  let(:context) do
    {
      current_component: blog_component
    }
  end
  let(:blog_component) { create :post_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is public" do
    let(:action) do
      { scope: :public, action: :foo, subject: :blogpost }
    end

    it { is_expected.to be true }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :blogpost }
    end

    it { is_expected.to be true }
  end

  context "when scope is a random one" do
    let(:action) do
      { scope: :foo, action: :foo, subject: :blogpost }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is a random one" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end
end
