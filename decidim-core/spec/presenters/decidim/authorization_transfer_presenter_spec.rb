# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationTransferPresenter, type: :presenter do
    subject { presenter }

    let(:presenter) { described_class.new(transfer) }

    let(:transfer) { create(:authorization_transfer) }
    let!(:records) { create_list(:authorization_transfer_record, 5, transfer: transfer) }

    shared_context "with actual records" do
      let(:comments) { create_list(:comment, 10) }
      let(:meetings) { create_list(:meeting, 3) }
      let(:proposals) { create_list(:proposal, 2) }
      let(:coauthorships) { proposals.map(&:coauthorships).reduce([], :+) }

      let!(:records) do
        (coauthorships + meetings + comments).map do |resource|
          create(:authorization_transfer_record, transfer: transfer, resource: resource)
        end
      end
    end

    describe "#translated_record_counts" do
      subject { presenter.translated_record_counts }

      it "returns the record types with their translated messages" do
        expect(subject).to eq(
          "Decidim::DummyResources::DummyResource" => "Dummy resource: 5"
        )
      end

      context "with actual records" do
        include_context "with actual records"

        it "returns the record types with their translated messages in sorted order" do
          expect(subject).to eq(
            "Decidim::Comments::Comment" => "Comments: 10",
            "Decidim::Meetings::Meeting" => "Meetings: 3",
            "Decidim::Proposals::Proposal" => "Proposals: 2"
          )
        end
      end
    end

    describe "#translated_record_texts" do
      subject { presenter.translated_record_texts }

      it "returns the record types with their translated messages" do
        expect(subject).to eq(["Dummy resource: 5"])
      end

      context "with actual records" do
        include_context "with actual records"

        it "returns the record types with their translated messages in sorted order" do
          expect(subject).to eq(
            ["Comments: 10", "Meetings: 3", "Proposals: 2"]
          )
        end
      end
    end

    describe "#records_list_html" do
      subject { presenter.records_list_html }

      it "returns the record types with their translated messages" do
        expect(subject).to eq("<ul><li>Dummy resource: 5</li></ul>")
      end

      it "marks the returned string as HTML safe" do
        expect(subject.html_safe?).to be(true)
      end

      context "with actual records" do
        include_context "with actual records"

        it "returns the record types with their translated messages in sorted order" do
          items = ["Comments: 10", "Meetings: 3", "Proposals: 2"].map { |msg| "<li>#{msg}</li>" }
          expect(subject).to eq(
            "<ul>#{items.join}</ul>"
          )
        end
      end
    end
  end
end
