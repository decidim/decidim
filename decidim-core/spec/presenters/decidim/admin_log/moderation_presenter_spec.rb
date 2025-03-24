# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::ModerationPresenter, type: :helper do
  subject(:presenter) { described_class.new(action_log, helper) }

  include_examples "present admin log entry" do
    let(:component) { create(:component, manifest_name: "dummy", organization:) }
    let(:reportable) { create(:dummy_resource, component:) }
    let(:moderation) { create(:moderation, reportable:) }
    let(:admin_log_resource) { create(:report, moderation:) }
    let(:action) { "unreport" }
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:action) { "create" }
  let(:admin_log_extra_data) { {} }
  let(:action_log) do
    create(
      :action_log,
      user:,
      action:,
      resource: admin_log_resource,
      extra_data: admin_log_extra_data
    )
  end

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    subject { presenter.present }

    context "when the logged action has extra data for the diff" do
      let(:admin_log_extra_data) do
        {
          "extra" => {
            "reportable_type" => "DummyResource",
            "reported_count" => 3,
            "reported_content" => { "title" => { "en" => "Example Title" } }
          }
        }
      end

      it "includes the reported content in the diff" do
        expect(subject).to include("Example Title")
      end
    end
  end

  describe "#action_string" do
    subject { presenter.send(:action_string) }

    context "when the action is 'unreport'" do
      let(:action) { "unreport" }

      it "returns the correct I18n key" do
        expect(subject).to eq("decidim.admin_log.moderation.unreport")
      end
    end
  end

  describe "#has_diff?" do
    subject { presenter.send(:has_diff?) }

    context "when the action is in the diff actions and changeset has data" do
      let(:action) { "bulk_hide" }

      before do
        allow(Decidim::Log::DiffChangesetCalculator).to receive(:new).and_return(instance_double(Decidim::Log::DiffChangesetCalculator, changeset: { key: "value" }))
      end

      it { is_expected.to be true }
    end

    context "when the action is not in the diff actions" do
      let(:action) { "create" }

      it { is_expected.to be false }
    end
  end
end
