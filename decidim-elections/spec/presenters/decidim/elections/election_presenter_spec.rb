# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ElectionPresenter, type: :helper do
      subject(:presenter) { described_class.new(election) }

      let(:election) { create :election, title: title, description: description }
      let(:title) do
        {
          "en" => "A title <br/> with a lot of <strong>HTML</strong> &amp; &quote;special characters&quote;"
        }
      end
      let(:description) do
        {
          "en" => "Election description and some spam links:<ul>\n" \
                  "<li><a href='http://example.org'>this is for SEO</a></li>\n" \
                  "<li><strong><a href='http://example.org'>visit this</a></strong></li></ul>"
        }
      end

      describe "#title" do
        subject { presenter.title }

        it "returns the title with html escaped" do
          expect(subject).to eq "A title &lt;br/&gt; with a lot of &lt;strong&gt;HTML&lt;/strong&gt; &amp;amp; &amp;quote;special characters&amp;quote;"
        end
      end

      describe "#description" do
        subject { presenter.description }

        it "returns the description with html tags" do
          expect(subject).to eq "Election description and some spam links:<ul>\n" \
                                "<li><a href='http://example.org'>this is for SEO</a></li>\n" \
                                "<li><strong><a href='http://example.org'>visit this</a></strong></li></ul>"
        end

        context "when stripping tags" do
          subject { presenter.description(strip_tags: true) }

          it "returns the description without html tags" do
            expect(subject).to eq "Election description and some spam links:\nthis is for SEO\nvisit this"
          end
        end
      end
    end
  end
end
