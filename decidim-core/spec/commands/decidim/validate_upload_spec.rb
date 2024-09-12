# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ValidateUpload do
    describe "call" do
      let(:command) { described_class.new(form) }
      let(:form) do
        double(
          invalid?: invalid,
          blob:,
          errors:
        )
      end
      let(:invalid) { false }
      let(:errors) { [] }
      let(:io) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
      let(:blob) { ActiveStorage::Blob.create_and_upload!(io:, filename: "city.jpeg") }

      describe "when form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "ignores file removal" do
          expect(ActiveStorage::Blob).not_to receive(:find_signed).with(blob)
          command.call
        end
      end

      describe "when the form is not valid" do
        let(:invalid) { true }
        let(:errors) { ["File too dummy"] }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid, errors)
        end

        it "removes the invalid file" do
          expect(blob).to receive(:purge_later)
          command.call
        end
      end
    end
  end
end
