# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  subject { action_log }

  let(:action_log) { build(:action_log) }

  it { is_expected.to be_valid }

  include_examples "has taxonomies"

  describe "validations" do
    context "when no user is given" do
      let(:action_log) { build(:action_log, user: nil, organization: build(:organization)) }

      it { is_expected.not_to be_valid }
    end

    context "when no action is given" do
      let(:action_log) { build(:action_log, action: nil) }

      it { is_expected.not_to be_valid }
    end

    context "when no organization is given" do
      let(:action_log) { build(:action_log, organization: nil, participatory_space: build(:participatory_process)) }

      it { is_expected.not_to be_valid }
    end

    context "when no resource is given" do
      let(:action_log) { build(:action_log, resource: nil) }

      it { is_expected.not_to be_valid }

      context "when the action is delete" do
        before do
          action_log.action = "delete"
        end

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid visibility is given" do
      let(:action_log) { build(:action_log, visibility: "foo") }

      it { is_expected.not_to be_valid }
    end

    context "when no visibility is given" do
      let(:action_log) { build(:action_log, visibility: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "readonly" do
    it "cannot be modified once saved" do
      action_log.save
      action_log.action = :my_new_action

      expect do
        action_log.save
      end.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "cannot be deleted" do
      action_log.save

      expect do
        action_log.destroy
      end.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe ".with_resource_type" do
    subject { described_class.with_resource_type(type_key) }

    let(:type_key) { publish_logs.first.resource.class.name }
    let!(:publish_logs) { create_list(:action_log, 2, action: "publish") }
    let!(:create_logs) { create_list(:action_log, 5) }

    let(:public_types) { %w(Decidim::Dev::DummyResource) }
    let(:publicable_types) { public_types }

    before do
      allow(described_class).to receive(:public_resource_types).and_return(public_types)
      allow(described_class).to receive(:publicable_public_resource_types).and_return(publicable_types)
    end

    context "with publicable resource type" do
      it "returns the correct resources" do
        expect(subject.count).to eq(publish_logs.count)
      end
    end

    context "with public but not publicable resource type" do
      let(:publicable_types) { [] }

      it "returns the correct resources" do
        expect(subject.count).to eq(publish_logs.count + create_logs.count)
      end
    end

    context "with non-public and non-publicable resource types" do
      let(:public_types) { %w(Decidim::Dev::DummyResource Decidim::Comments::Comment) }
      let(:publicable_types) { %w(Decidim::Dev::DummyResource) }

      let(:type_key) { "Decidim::UnexistingResource" }
      let!(:create_logs) { create_list(:action_log, 5, resource: create(:comment)) }

      # In this situation it should return:
      # 1. All publicable resources with action not matching with "create"
      # 2. All public resource types with any action
      it "returns the correct resources" do
        expect(subject.count).to eq(publish_logs.count + create_logs.count)
      end
    end
  end

  describe ".with_new_resource_type" do
    subject { described_class.with_new_resource_type(type_key) }

    let(:type_key) { publish_logs.first.resource.class.name }
    let!(:publish_logs) { create_list(:action_log, 2, action: "publish") }
    let!(:create_logs) { create_list(:action_log, 5) }

    let(:public_types) { %w(Decidim::Dev::DummyResource) }
    let(:publicable_types) { public_types }

    before do
      allow(described_class).to receive(:public_resource_types).and_return(public_types)
      allow(described_class).to receive(:publicable_public_resource_types).and_return(publicable_types)
    end

    context "with publicable resource type" do
      it "returns the correct resources" do
        expect(subject.count).to eq(publish_logs.count)
      end
    end

    context "with public but not publicable resource type" do
      let(:publicable_types) { [] }

      it "returns the correct resources" do
        expect(subject.count).to eq(create_logs.count)
      end
    end

    context "with non-public and non-publicable resource types" do
      let(:public_types) { %w(Decidim::Dev::DummyResource Decidim::Comments::Comment) }
      let(:publicable_types) { %w(Decidim::Dev::DummyResource) }

      let(:type_key) { "Decidim::UnexistingResource" }
      let!(:create_logs) { create_list(:action_log, 5, resource: create(:comment)) }

      # In this situation it should return:
      # 1. All publicable resources with action "publish"
      # 2. All public resource types with action "create"
      it "returns the correct resources" do
        expect(subject.count).to eq(publish_logs.count + create_logs.count)
      end
    end
  end

  describe "#visible_for?" do
    subject { action_log.visible_for?(user) }

    let(:action_log) { create(:action_log) }
    let(:user) { instance_double(Decidim::User) }

    before do
      action_log.resource.publish!
    end

    context "when the resource has been hidden" do
      before do
        create(:moderation, :hidden, reportable: action_log.resource)
      end

      it { is_expected.to be_falsey }
    end

    context "when there is no resource" do
      before do
        action_log.resource.delete
      end

      it { is_expected.to be_falsey }
    end

    context "when there is no participatory space" do
      before do
        action_log.participatory_space.delete
      end

      it { is_expected.to be_falsey }
    end

    context "when the user cannot participate" do
      before do
        action_log.participatory_space.private_space = true
        action_log.participatory_space.save!
        expect(user).to receive(:id)
      end

      it { is_expected.to be_falsey }
    end

    context "when resource does not exist" do
      before do
        allow(Rails.logger).to receive(:warn).at_least(:once)
        action_log.resource_type = "ANonExistingClass"
        action_log.participatory_space.save!
      end

      it "creates a log entry" do
        expect(subject).to be_falsey
        expect(Rails.logger).to have_received(:warn).with(/Failed resource/).once
      end
    end

    it { is_expected.to be_truthy }
  end

  describe "#user_lazy" do
    subject { action_log.user_lazy }

    let(:action_log) { create(:action_log) }

    it "returns the lazy-loaded user" do
      expect(subject).to be_a(Decidim::User)
    end

    context "with api user" do
      let!(:user) { create(:api_user) }
      let(:action_log) { create(:action_log, user:) }

      it "returns the lazy-loaded user" do
        expect(subject).to be_a(Decidim::Api::ApiUser)
      end
    end
  end
end
