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
        expect(wrapper.renew_path).to eq("/authorizations/renew?handler=dummy_authorization_handler")
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
        expect(wrapper.renew_path).to eq("/dummy_authorization_workflow/renew_authorization")
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

  describe "#resume_authorization_path", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
    let(:handler) { "dummy_authorization_workflow" }
    let(:wrapper) { described_class.from_element(handler) }

    it "returns the edit authorization path for the workflow engine" do
      expect(wrapper.resume_authorization_path).to eq("/dummy_authorization_workflow/edit_authorization")
    end

    context "when the main engine is not defined" do
      it "raises a MissingEngine error" do
        allow(wrapper).to receive(:respond_to?).with("decidim_#{handler}").and_return(false)

        expect { wrapper.resume_authorization_path }.to raise_error(
          Decidim::Verifications::MissingEngine
        )
      end
    end

    context "when the edit_authorization_path is not defined for the engine" do
      it "raises a MissingVerificationRoute error" do
        allow(wrapper).to receive(:decidim_dummy_authorization_workflow).and_return(double)

        expect { wrapper.resume_authorization_path }.to raise_error(
          Decidim::Verifications::MissingVerificationRoute
        )
      end
    end

    context "with direct verification" do
      let(:handler) { "dummy_authorization_handler" }

      it "raises an InvalidVerificationRoute error" do
        expect { wrapper.resume_authorization_path }.to raise_error(
          Decidim::Verifications::InvalidVerificationRoute
        )
      end
    end
  end

  describe "#renew_path", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
    let(:handler) { "dummy_authorization_workflow" }
    let(:wrapper) { described_class.from_element(handler) }

    it "returns the renew authorization path for the workflow engine" do
      expect(wrapper.renew_path).to eq("/dummy_authorization_workflow/renew_authorization")
    end

    context "when the main engine is not defined" do
      it "raises a MissingEngine error" do
        allow(wrapper).to receive(:respond_to?).with("decidim_#{handler}").and_return(false)

        expect { wrapper.renew_path }.to raise_error(
          Decidim::Verifications::MissingEngine
        )
      end
    end

    context "when the edit_authorization_path is not defined for the engine" do
      it "raises a MissingVerificationRoute error" do
        allow(wrapper).to receive(:decidim_dummy_authorization_workflow).and_return(double)

        expect { wrapper.renew_path }.to raise_error(
          Decidim::Verifications::MissingVerificationRoute
        )
      end
    end

    context "with direct verification" do
      let(:handler) { "dummy_authorization_handler" }

      it "returns the general renew authorization path" do
        expect(wrapper.renew_path).to eq("/authorizations/renew?handler=dummy_authorization_handler")
      end
    end
  end

  describe "#admin_root_path", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow id_documents) do
    let(:handler) { "id_documents" }
    let(:wrapper) { described_class.from_element(handler) }

    it "returns the renew authorization path for the workflow engine" do
      expect(wrapper.admin_root_path).to eq("/admin/id_documents/")
    end

    context "when the admin engine is not defined" do
      let(:handler) { "dummy_authorization_workflow" }

      it "raises a MissingEngine error" do
        expect { wrapper.admin_root_path }.to raise_error(
          Decidim::Verifications::MissingEngine
        )
      end
    end

    context "with direct verification" do
      let(:handler) { "dummy_authorization_handler" }

      it "raises an InvalidVerificationRoute error" do
        expect { wrapper.admin_root_path }.to raise_error(
          Decidim::Verifications::InvalidVerificationRoute
        )
      end
    end
  end
end
