# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe SignPollingStationClosure do
    subject { described_class.new(form, closure) }

    let(:closure) { create(:ps_closure) }
    let(:context) { { closure: } }

    let(:params) do
      {
        signed:
      }
    end
    let(:signed) { true }

    let(:form) { ClosureSignForm.from_params(params).with_context(context) }

    context "when the form is not valid" do
      let(:signed) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when the closure is signed" do
      let(:signed) { true }

      it "saves a timestamp" do
        subject.call

        expect(closure.signed_at).to be_present
        expect(closure.signed_at).to be_kind_of(Date)
        expect(closure.signed?).to be true
      end

      it "changes to complete phase" do
        subject.call

        expect(closure.complete_phase?).to be true
      end
    end
  end
end
