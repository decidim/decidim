# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::RemoveTrusteeFromParticipatorySpace do
  subject { described_class.new(trustee, current_participatory_space) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:current_participatory_space) { create :participatory_process, organization: organization }
  let(:trustee) { create :trustee }

  it "removes participatory space from trustee" do
    subject.call
    expect(trustee.trustees_participatory_spaces).not_to include(current_participatory_space)
  end

  context "when trustee has elections" do
    let(:trustee) { create :trustee, :with_elections }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
