# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateImport do
    subject { described_class.new(form) }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let!(:component) { create(:dummy_component, organization: organization) }
    let(:file) { Decidim::Dev.test_file("verify_user_groups.csv", "text/csv") }

    let(:form) do
      Decidim::Admin::ImportForm.from_params(
        component: component,
        file: file,
        creator: Decidim::Admin::Import::Creator
      ).with_context(
        current_organization: organization,
        current_component: component,
        current_user: user
      )
    end

    describe "when everything is ok" do
      it "returns broadcast ok" do
        record = double("record", save!: double("record"))
        importer = instance_double("importer", prepare: [record], invalid_lines: [], import!: record.save!)
        allow(subject).to receive(:importer_for).and_return(importer)
        allow(form).to receive(:check_invalid_lines).and_return([])
        allow(form).to receive(:importer).and_return(importer)
        expect do
          subject.call
        end.to broadcast(:ok)
      end
    end

    describe "when something unexpected happens" do
      it "returns broadcast invalid" do
        importer = double
        allow(subject).to receive(:importer_for).with(file.tempfile.path, file.content_type).and_return(importer)
        expect(importer).to receive(:prepare)
        allow(importer).to receive(:invalid_lines).and_return([])
        allow(importer).to receive(:import!).and_raise(StandardError)
        allow(form).to receive(:check_invalid_lines).and_return([])
        allow(form).to receive(:importer).and_return(importer)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
