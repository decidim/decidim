# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PrivateDownload do
    subject(:private_download) { described_class.for(record, attachment_name: :file, variant:) }

    let(:record) { create(:attachment, :with_image) }
    let(:variant) { nil }

    describe "#token" do
      [:thumbnail, :big].each do |variant_name|
        context "with the #{variant_name} variant" do
          let(:variant) { variant_name }

          it "round-trips the variant" do
            round_tripped = described_class.from_token(private_download.token)

            expect(round_tripped.variant).to eq(variant_name)
          end

          it "resolves to the processed variant" do
            round_tripped = described_class.from_token(private_download.token)
            processed_variant = record.attached_uploader(:file).variant(variant_name).processed

            expect(round_tripped.representation.download).to eq(processed_variant.download)
          end
        end
      end
    end

    describe "#representation" do
      context "when no variant is given" do
        it "returns the original attachment" do
          expect(private_download.representation).to eq(record.file)
        end
      end

      context "when the token was generated without a variant" do
        let(:token) do
          described_class.verifier.generate(
            { gid: record.to_global_id.to_s, attachment_name: "file" },
            purpose: described_class::VERIFIER_PURPOSE
          )
        end

        it "returns the original attachment" do
          round_tripped = described_class.from_token(token)

          expect(round_tripped.variant).to be_nil
          expect(round_tripped.representation.download).to eq(record.file.download)
        end
      end

      context "with an unknown variant" do
        let(:variant) { :unknown }

        it "falls back to the original attachment without raising" do
          expect { private_download.representation }.not_to raise_error
          expect(private_download.representation).to eq(record.file)
        end
      end

      context "when the image cannot be varied" do
        let(:variant) { :thumbnail }

        before do
          allow(ActiveStorage).to receive(:variable_content_types).and_return(%w(image/bmp))
        end

        it "falls back to the original attachment" do
          expect(private_download.representation).to eq(record.file)
        end
      end

      context "when the attachment is not an image" do
        let(:record) { create(:attachment, :with_pdf) }
        let(:variant) { :thumbnail }

        it "falls back to the original attachment" do
          expect(private_download.representation).to eq(record.file)
        end
      end

      context "when the record does not respond to attached_uploader" do
        let(:record) { create(:private_export) }
        let(:variant) { :thumbnail }

        it "returns the original attachment" do
          expect(private_download.representation).to eq(record.file)
        end

        it "round-trips the variant through the token" do
          round_tripped = described_class.from_token(private_download.token)

          expect(round_tripped.variant).to eq(:thumbnail)
          expect(round_tripped.representation.download).to eq(record.file.download)
        end
      end
    end
  end
end
