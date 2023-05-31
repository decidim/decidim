# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateImportExample do
    subject { described_class.new(form) }

    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:dummy_component, organization:) }
    let(:format) { "csv" }

    let(:form) do
      Decidim::Admin::ImportExampleForm.from_params(
        name: "dummies",
        format:
      ).with_context(
        current_organization: organization,
        current_component: component
      )
    end

    describe "when everything is ok" do
      it "returns broadcast ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    describe "when the form is invalid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "returns broadcast invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
