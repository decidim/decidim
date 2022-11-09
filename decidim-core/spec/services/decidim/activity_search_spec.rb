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
      described_class.new(organization: organization, resource_type: resource_type, current_user: current_user)
    end
    let(:current_user) { nil }
    let(:organization) { create(:organization) }
    let(:resource_type) { "all" }

    context "with admin logs" do
      let!(:admin_log) { create(:action_log, visibility: "admin-only", organization: organization) }

      it { is_expected.not_to include(admin_log) }
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

    context "when a resource is hidden through moderation" do
      let(:comment) { create(:comment) }
      let!(:action_log) do
        create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization)
      end
      let!(:moderation) do
        create(
          :moderation,
          :hidden,
          reportable: comment,
          participatory_space: comment.commentable.participatory_space
        )
      end

      it { is_expected.not_to include(action_log) }
    end

    context "when a resource is hidden through a private space" do
      let(:current_user) { create(:user, :confirmed, organization: organization) }
      let(:participatory_process) { create(:participatory_process, :private, organization: organization) }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component: component) }
      let(:comment) { create(:comment, commentable: commentable) }
      let!(:action_log) do
        create(
          :action_log,
          action: "create",
          visibility: "public-only",
          resource: comment,
          participatory_space: participatory_process,
          organization: organization
        )
      end

      it { is_expected.not_to include(action_log) }

      context "and the user is in the private space users" do
        before do
          create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process)
        end

        it { is_expected.to include(action_log) }
      end
    end

    context "when a public space has private users" do
      let(:current_user) { create(:user, :confirmed, organization: organization) }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:process) { create(:participatory_process, organization: organization) }
      let(:assembly) { create(:assembly, organization: organization) }
      let(:private_process) { create(:participatory_process, :private, organization: organization) }
      let(:private_assembly) { create(:assembly, :private, organization: organization) }

      let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
      let(:comment) { create(:comment, author: user, commentable: build(:dummy_resource, component: component)) }
      let!(:log) { create(:action_log, action: "create", visibility: "public-only", resource: comment, participatory_space: process, user: user) }

      let(:private_component) { create(:component, manifest_name: "dummy", participatory_space: private_process) }
      let(:private_comment) { create(:comment, author: user, commentable: build(:dummy_resource, component: private_component)) }
      let!(:private_log) { create(:action_log, action: "create", visibility: "public-only", resource: private_comment, participatory_space: private_process, user: user) }

      before do
        # Note that it is possible to add private users also to public processes
        # and assemblies, there is no programming logic forbidding that to happen.
        [process, assembly, private_process, private_assembly].each do |space|
          10.times { create(:participatory_space_private_user, user: build(:user, :confirmed, organization: organization), privatable_to: space) } # rubocop:disable FactoryBot/CreateList
        end

        # Add the user to both private spaces
        create(:participatory_space_private_user, user: user, privatable_to: private_process)
        create(:participatory_space_private_user, user: user, privatable_to: private_assembly)
      end

      it "does not return duplicates" do
        expect(subject.count).to eq(1)
      end

      context "when the current user has access to the private space" do
        before do
          create(:participatory_space_private_user, user: current_user, privatable_to: private_process)
        end

        it "returns also the private comment without duplicates" do
          expect(subject.count).to eq(2)
        end
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
