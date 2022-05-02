# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:user) { nil }
    let(:context) { {} }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }
    let(:action_name) { :foo }
    let(:action_subject) { :bar }
    let(:action) do
      { scope: :public, action: action_name, subject: action_subject }
    end
    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component: component) }
    let(:comment) { create(:comment, commentable: commentable) }

    # When the subject is not a comment
    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end

    context "with an unknown action" do
      let(:action_subject) { :comment }

      it "raises a PermissionNotSetError" do
        expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
      end
    end

    context "when creating a comment" do
      let(:action_name) { :create }
      let(:action_subject) { :comment }
      let(:context) { { commentable: commentable } }

      # Without any user
      it { is_expected.to be false }

      context "with a user who is allowed to comment" do
        let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }

        it { is_expected.to be true }

        context "with comments disabled for the component" do
          let(:component) { create(:component, :with_comments_disabled, participatory_space: participatory_process) }

          it { is_expected.to be false }
        end
      end

      context "with a user who is not allowed to comment" do
        let(:participatory_process) { create :participatory_process, :private, organization: organization }
        let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }

        it { is_expected.to be false }
      end
    end

    context "when voting a comment" do
      let(:action_name) { :create }
      let(:action_subject) { :comment }
      let(:context) { { comment: comment } }

      # Without any user
      it { is_expected.to be false }

      context "with a user who is allowed to comment" do
        let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }

        it { is_expected.to be true }

        context "with comments disabled for the component" do
          before do
            # If the comments are not enabled when creating the comment, it
            # would raise a validation exception.
            context
            component.settings[:comments_enabled] = false
            component.save!
          end

          it { is_expected.to be true }
        end
      end

      context "with a user who is not allowed to comment" do
        let(:participatory_process) { create :participatory_process, :private, organization: organization }
        let(:user) { create(:user, :confirmed, locale: "en", organization: organization) }

        it { is_expected.to be false }
      end
    end
  end
end
