# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateImport do
    subject { described_class.new(form) }

    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let!(:component) { create(:dummy_component, organization:) }
    let(:file) { upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv")) }

    let(:form) do
      Decidim::Admin::ImportForm.from_params(
        component:,
        file:,
        name: "dummies"
      ).with_context(
        current_organization: organization,
        current_component: component,
        current_user: user
      )
    end

    describe "when everything is ok" do
      it "returns broadcast ok" do
        record = double("record", save!: double("record"))
        importer = instance_double("importer", prepare: [record], invalid_indexes: [], import!: record.save!)
        allow(importer).to receive(:invalid_file?).and_return(false)
        allow(importer).to receive(:verify).and_return(true)
        allow(subject).to receive(:importer).and_return(importer)
        allow(form).to receive(:importer).and_return(importer)
        expect do
          subject.call
        end.to broadcast(:ok)
      end
    end

    describe "when something unexpected happens" do
      it "returns broadcast invalid" do
        importer = double
        allow(importer).to receive(:invalid_indexes_message).and_return("Invalid")
        allow(importer).to receive(:invalid_file?).and_return(true)
        allow(form).to receive(:importer).and_return(importer)
        expect(importer).not_to receive(:prepare)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
