# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe InvitePresenter, type: :helper do
    let(:invite) { build_stubbed(:invite, sent_at: nil) }

    describe "#status" do
      subject { described_class.new(invite).status }

      it { is_expected.to eq "-" }

      context "when invited was sent" do
        let(:invite) { build_stubbed(:invite) }

        it { is_expected.to eq "Sent" }
      end

      context "when invited was accepted" do
        let(:invite) { build_stubbed(:invite, :accepted) }

        it { is_expected.to eq "Accepted (#{I18n.l(invite.accepted_at, format: :decidim_short)})" }
      end

      context "when invited was rejected" do
        let(:invite) { build_stubbed(:invite, :rejected) }

        it { is_expected.to eq "Rejected (#{I18n.l(invite.rejected_at, format: :decidim_short)})" }
      end
    end

    describe "#status_html_class" do
      subject { described_class.new(invite).status_html_class }

      it { is_expected.to eq "" }

      context "when invited was sent" do
        let(:invite) { build_stubbed(:invite) }

        it { is_expected.to eq "warning" }
      end

      context "when invited was accepted" do
        let(:invite) { build_stubbed(:invite, :accepted) }

        it { is_expected.to eq "success" }
      end

      context "when invited was rejected" do
        let(:invite) { build_stubbed(:invite, :rejected) }

        it { is_expected.to eq "danger" }
      end
    end
  end
end
