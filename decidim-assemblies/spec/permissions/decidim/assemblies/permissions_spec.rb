# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:assembly) { create :assembly, organization: organization }
  let(:context) { { current_participatory_space: assembly } }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when the user is not related to the assembly" do
    context "when the action is for the admin" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dashboard }
      end

      it { is_expected.to eq false }
    end

    context "when the action is for the public part" do
      let(:action) do
        { scope: :public, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end
  end

  context "when the user is an organization admin" do
    let(:user) { create :user, :admin, organization: organization }

    context "when the action is for the admin dashboard" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dashboard }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for moderating resources" do
      let(:action) do
        { scope: :admin, action: :hide, subject: :moderation }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a read one for the admin" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a random one for the admin" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :bar }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for the public part" do
      let(:action) do
        { scope: :public, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end
  end

  context "when the user is a assembly admin" do
    let(:user) { create :assembly_admin, assembly: assembly }

    context "when the action is for the admin dashboard" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dashboard }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for moderating resources" do
      let(:action) do
        { scope: :admin, action: :hide, subject: :moderation }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a read one for the admin" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a random one for the admin" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :bar }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for the public part" do
      let(:action) do
        { scope: :public, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end
  end

  context "when the user is a assembly collaborator" do
    let(:user) { create :assembly_collaborator, assembly: assembly }

    context "when the action is for the admin dashboard" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dashboard }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for moderating resources" do
      let(:action) do
        { scope: :admin, action: :hide, subject: :moderation }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a read one for the admin" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a random one for the admin" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :bar }
      end

      it { is_expected.to eq false }
    end

    context "when the action is for the public part" do
      let(:action) do
        { scope: :public, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end
  end

  context "when the user is a assembly moderator" do
    let(:user) { create :assembly_moderator, assembly: assembly }

    context "when the action is for the admin dashboard" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dashboard }
      end

      it { is_expected.to eq true }
    end

    context "when the action is for moderating resources" do
      let(:action) do
        { scope: :admin, action: :hide, subject: :moderation }
      end

      it { is_expected.to eq true }
    end

    context "when the action is a read one for the admin" do
      let(:action) do
        { scope: :admin, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq false }
    end

    context "when the action is a random one for the admin" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :bar }
      end

      it { is_expected.to eq false }
    end

    context "when the action is for the public part" do
      let(:action) do
        { scope: :public, action: :read, subject: :dummy_resource }
      end

      it { is_expected.to eq true }
    end
  end
end
