# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:consultation) { create :consultation, organization: organization }
  let(:question) { create :question, consultation: consultation }
  let(:context) { { consultation: consultation, question: question } }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when the action is for the admin part" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it_behaves_like "delegates permissions to", Decidim::Consultations::Admin::Permissions
  end

  context "when the action is for the public part" do
    let(:action_name) { :read }
    let(:action) do
      { scope: :public, action: action_name, subject: action_subject }
    end

    context "when reading a consultation" do
      let(:action_subject) { :consultation }

      context "when the consultation is published" do
        let(:consultation) { create :consultation, :published, organization: organization }

        it { is_expected.to be true }
      end

      context "when the consultation is not published" do
        let(:consultation) { create :consultation, :unpublished, organization: organization }

        context "when the user is not an admin" do
          let(:user) { nil }

          it { is_expected.to be false }
        end

        context "when the user is an admin" do
          let(:user) { create :user, :admin, organization: organization }

          it { is_expected.to be true }
        end
      end
    end

    context "when reading a question" do
      let(:action_subject) { :question }

      context "when the question is published" do
        let(:question) { create :question, :published, consultation: consultation }

        it { is_expected.to be true }
      end

      context "when the question is not published" do
        let(:question) { create :question, :unpublished, consultation: consultation }

        context "when the user is not an admin" do
          let(:user) { nil }

          it { is_expected.to be false }
        end

        context "when the user is an admin" do
          let(:user) { create :user, :admin, organization: organization }

          it { is_expected.to be true }
        end
      end
    end

    context "when voting a question" do
      let(:action_subject) { :question }
      let(:action_name) { :vote }

      before do
        allow(question)
          .to receive(:can_be_voted_by?)
          .with(user)
          .and_return(votable)
      end

      context "when the question can be voted by the user" do
        let(:votable) { true }

        it { is_expected.to be true }
      end

      context "when the question cannot be voted by the user" do
        let(:votable) { false }

        it { is_expected.to be false }
      end
    end

    context "when unvoting a question" do
      let(:action_subject) { :question }
      let(:action_name) { :unvote }

      before do
        allow(question)
          .to receive(:can_be_unvoted_by?)
          .with(user)
          .and_return(unvotable)
      end

      context "when the question can be unvoted by the user" do
        let(:unvotable) { true }

        it { is_expected.to be true }
      end

      context "when the question cannot be unvoted by the user" do
        let(:unvotable) { false }

        it { is_expected.to be false }
      end
    end
  end
end
