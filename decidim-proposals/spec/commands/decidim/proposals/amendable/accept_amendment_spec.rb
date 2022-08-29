# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Accept do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create :amendment, amendable:, emendation: }
      let(:command) { described_class.new(form) }

      let(:emendation_params) do
        {
          title: translated(emendation.title),
          body: translated(emendation.body)
        }
      end

      let(:form_params) do
        {
          id: amendment.id,
          emendation_params:
        }
      end

      let(:form) { Decidim::Amendable::ReviewForm.from_params(form_params) }

      include_examples "accept amendment" do
        it "changes the emendation state" do
          expect { command.call }.to change { emendation.reload[:state] }.from(nil).to("accepted")
        end
      end
    end
  end
end
