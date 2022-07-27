# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::RemoveTrusteeFromParticipatorySpace do
  subject { described_class.new(trustee_participatory_space) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:trustee_participatory_space) { create :trustees_participatory_space }
  let(:current_participatory_space) { trustee_participatory_space.participatory_space }

  it "removes participatory space from trustee" do
    subject.call
    expect(trustee_participatory_space.trustee.trustees_participatory_spaces).not_to include(current_participatory_space)
  end

  context "when trustee has elections" do
    let(:trustee) { create :trustee, :with_elections }
    let(:trustee_participatory_space) { create :trustees_participatory_space, trustee: }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
