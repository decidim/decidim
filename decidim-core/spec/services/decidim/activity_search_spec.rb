# frozen_string_literal: true

require "spec_helper"

module Decidim
  ActivitySearch.class_eval do
    def resource_types
      %w(
        Decidim::Comments::Comment
        Decidim::DummyResources::DummyResource
      )
    end
  end

  describe ActivitySearch do
    subject { search.results }

    let(:search) do
      described_class.new(organization: organization, resource_type: resource_type)
    end
    let(:organization) { create(:organization) }
    let(:resource_type) { "all" }

    context "with admin logs" do
      let!(:admin_log) { create(:action_log, visibility: "admin-only", organization: organization) }

      it { is_expected.not_to eq(admin_log) }
    end

    context "when a resource is not publicable" do
      let(:comment) { create(:comment) }
      let!(:action_log) do
        create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization)
      end

      it { is_expected.to include(action_log) }
    end

    context "with any other actions" do
      let!(:action_log) do
        create(:action_log, action: "update", visibility: "public-only", organization: organization)
      end

      it { is_expected.to include(action_log) }
    end

    context "when a resource is publicable" do
      let!(:action_log) do
        create(:action_log, action: action, visibility: "all", resource: resource, organization: organization, participatory_space: component.participatory_space)
      end
      let(:component) do
        create(:component, :published, organization: organization)
      end

      context "and it is not published" do
        let(:action) { "create" }
        let(:resource) do
          create(:dummy_resource, component: component, published_at: nil)
        end

        it { is_expected.not_to include(action_log) }
      end

      context "and it is published" do
        let(:action) { "publish" }
        let(:resource) do
          create(:dummy_resource, component: component, published_at: Time.current)
        end

        it { is_expected.to include(action_log) }
      end
    end

    context "with followed resources and interesting scopes" do
      let(:comment) { create(:comment) }
      let(:user) { create(:user, organization: organization) }
      let(:user2) { create(:user, organization: organization) }

      let(:component) do
        create(:component, :published, organization: organization)
      end

      let(:component2) do
        create(:component, :published, organization: organization)
      end

      let(:component3) do
        create(:component, :published, organization: organization)
      end

      let(:resource) do
        create(:dummy_resource, component: component, published_at: Time.current)
      end

      let(:resource2) do
        create(:dummy_resource, component: component2, published_at: Time.current)
      end

      let(:scoped_resource) do
        create(:dummy_resource, component: component3, published_at: Time.current)
      end

      let!(:uninteresting_resource) do
        create(:dummy_resource, component: component3, published_at: Time.current)
      end

      let(:interesting_scope) do
        scoped_resource.scope
      end

      let!(:followed_user_action_log) do
        create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization, user: user2)
      end

      let!(:followed_space_action_log) do
        create(:action_log, action: "publish", visibility: "all", resource: resource, organization: organization, participatory_space: component.participatory_space)
      end

      let!(:followed_resource_action_log) do
        create(:action_log, action: "publish", visibility: "all", resource: resource2, organization: organization)
      end

      let!(:scoped_resource_action_log) do
        create(:action_log, action: "publish", visibility: "all", resource: scoped_resource, organization: organization, scope: scoped_resource.scope)
      end

      let!(:uninteresting_resource_action_log) do
        create(:action_log, action: "publish", visibility: "all", resource: uninteresting_resource, organization: organization)
      end

      let(:search) do
        described_class.new(
          organization: organization,
          resource_type: resource_type,
          follows: user.following_follows,
          scopes: [interesting_scope]
        )
      end

      before do
        Decidim::Follow.create!(user: user, followable: user2)
        Decidim::Follow.create!(user: user, followable: followed_space_action_log.participatory_space)
        Decidim::Follow.create!(user: user, followable: resource2)
      end

      it "includes results performed by followed users" do
        expect(subject).to include(followed_user_action_log)
      end

      it "includes results from followed spaces" do
        expect(subject).to include(followed_space_action_log)
      end

      it "includes results from interesting scopes" do
        expect(subject).to include(scoped_resource_action_log)
      end

      it "includes results from followed resources" do
        expect(subject).to include(followed_resource_action_log)
      end

      it "does not include results from uninteresting resources" do
        expect(subject).not_to include(uninteresting_resource_action_log)
      end
    end
  end
end
