# frozen_string_literal: true

require "spec_helper"

shared_examples "present admin log entry" do
  subject(:presenter) { described_class.new(action_log, helper) }

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

    context "when the logged action is one that shows diff and the action log does not have an associated version" do
      it "returns an empty diff" do
        expect(subject).not_to include("class=\"logs__log__diff\"")
      end
    end
  end
end
