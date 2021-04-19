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
  end
end
