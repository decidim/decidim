# frozen_string_literal: true

require "spec_helper"

describe Decidim, with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
  describe ".authorization_handlers" do
    it "returns an array of authorization handlers" do
      auth_handlers = described_class.authorization_handlers

      expect(auth_handlers.map(&:name)).to eq(["dummy_authorization_handler"])
      expect(auth_handlers.map(&:type)).to eq(["direct"])
    end
  end

  describe ".authorization_engines" do
    it "returns an array of workflow manifests" do
      auth_engines = described_class.authorization_engines

      expect(auth_engines.map(&:name)).to eq(["dummy_authorization_workflow"])
      expect(auth_engines.map(&:type)).to eq(["multistep"])
    end
  end

  describe ".authorization_workflows" do
    it "returns an array of workflow manifests" do
      auth_workflows = described_class.authorization_workflows

      expect(auth_workflows.map(&:name)).to eq(%w(dummy_authorization_handler dummy_authorization_workflow))
      expect(auth_workflows.map(&:type)).to eq(%w(direct multistep))
    end
  end
end
