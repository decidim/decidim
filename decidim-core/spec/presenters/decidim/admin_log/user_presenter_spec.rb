# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::UserPresenter, type: :helper do
  context "when action is officialize" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { organization }
      let(:action) { "officialize" }
    end
  end

  context "when action is block" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { organization }
      let(:action) { "block" }
    end

    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :blocked, organization:) }
      let(:admin_log_extra_data) { { resource: { title: "John Doe" } } }
      let(:action) { "block" }

      describe "#present" do
        subject { presenter.present }

        it "presents the blocked user's name prior to blocking" do
          expect(subject).not_to include("Blocked user")
          expect(subject).to include(admin_log_extra_data[:resource][:title])
        end
      end
    end
  end
end
