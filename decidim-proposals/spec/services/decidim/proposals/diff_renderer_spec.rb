# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe DiffRenderer do
      subject { described_class.new(version).diff }

      let(:proposal) { create(:proposal) }
      let(:version) { PaperTrail::Version.create(item: proposal, event: "update", object_changes: { title: [title, other_title] }) }

      context "with title as string" do
        let(:title) { generate(:title) }
        let(:other_title) { generate(:title) }

        it "renders an empty diff" do
          expect(subject).to be_empty
        end
      end

      context "with title as translatable string" do
        let(:title) { generate_localized_title(:proposal_title, skip_injection: true) }
        let(:other_title) { generate_localized_title(:proposal_title, skip_injection: true) }

        it "renders the diff successfully" do
          expect(subject.dig(:title_en, :old_value)).to eq(title[:en])
          expect(subject.dig(:title_en, :new_value)).to eq(other_title[:en])
        end
      end
    end
  end
end
