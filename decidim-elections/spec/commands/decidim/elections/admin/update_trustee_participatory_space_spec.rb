# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::UpdateTrusteeParticipatorySpace do
  subject { described_class.new(trustee_participatory_space) }

  let(:trustee_participatory_space) { create :trustees_participatory_space }

  it "toggles the considered status" do
    subject.call
    expect(trustee_participatory_space.considered).to be(false)
  end

  context "when trustee_participatory_space is missing" do
    let(:trustee_participatory_space) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
