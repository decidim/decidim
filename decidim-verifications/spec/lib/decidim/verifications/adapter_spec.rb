# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::Adapter do
  describe ".from_element" do
    context "with a handler", with_authorization_workflows: ["dummy_authorization_handler"] do
      let(:wrapper) do
        described_class.from_element("dummy_authorization_handler")
      end

      it "returns a wrapper with the right interface" do
        expect(wrapper.name).to eq("dummy_authorization_handler")
        expect(wrapper.key).to eq("dummy_authorization_handler")
        expect(wrapper.root_path).to eq("/authorizations/new?handler=dummy_authorization_handler")
      end
    end

    context "with a workflow", with_authorization_workflows: ["dummy_authorization_workflow"] do
      let(:wrapper) do
        described_class.from_element("dummy_authorization_workflow")
      end

      it "returns a wrapper with the right interface" do
        expect(wrapper.name).to eq("dummy_authorization_workflow")
        expect(wrapper.key).to eq("dummy_authorization_workflow")
        expect(wrapper.root_path).to eq("/dummy_authorization_workflow/")
      end
    end
  end

  describe ".from_collection", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
    let(:wrappers) do
      described_class.from_collection(
        %w(dummy_authorization_handler dummy_authorization_workflow)
      )
    end

    it "returns an array of wrappers" do
      expect(wrappers.map(&:name)).to eq(%w(dummy_authorization_handler dummy_authorization_workflow))
      expect(wrappers.map(&:type)).to eq(%w(direct multistep))
    end
  end
end
