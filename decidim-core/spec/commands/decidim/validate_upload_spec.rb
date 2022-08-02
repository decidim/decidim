# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ValidateUpload do
    describe "call" do
      let(:command) { described_class.new(form) }
      let(:form) do
        double(
          invalid?: invalid,
          errors:
        )
      end
      let(:invalid) { false }
      let(:errors) { [] }

      describe "when form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end
      end

      describe "when the form is not valid" do
        let(:invalid) { true }
        let(:errors) { ["File too dummy"] }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid, errors)
        end
      end
    end
  end
end
