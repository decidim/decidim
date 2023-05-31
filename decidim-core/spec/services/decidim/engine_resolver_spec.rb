# frozen_string_literal: true

require "spec_helper"

describe Decidim::EngineResolver do
  subject { resolver }

  let(:resolver) { described_class.new(route_set) }
  let(:mounted_helpers) do
    Class.new { include Rails.application.routes.mounted_helpers }.new
  end
  let(:route_set) { mounted_helpers.public_send(mounted_engine_name).routes }
  let(:mounted_engine_name) { :decidim }

  describe "#mounted_name" do
    subject { resolver.mounted_name }

    it "resolves the correct name for the core module" do
      expect(subject).to eq("decidim")
    end

    context "when in the main app" do
      let(:route_set) { Rails.application.routes }

      it "resolves the main_app name" do
        expect(subject).to eq("main_app")
      end
    end

    context "when in a participatory process" do
      let(:mounted_engine_name) { :decidim_participatory_processes }

      it "resolves the correct name for the space" do
        expect(subject).to eq("decidim_participatory_processes")
      end
    end

    context "when in a component" do
      let(:mounted_engine_name) { :decidim_participatory_process_dummy }

      it "resolves the correct name for the component" do
        expect(subject).to eq("decidim_participatory_process_dummy")
      end
    end
  end
end
