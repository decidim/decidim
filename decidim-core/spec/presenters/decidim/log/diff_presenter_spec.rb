# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::DiffPresenter, type: :helper do
  subject { described_class.new(changeset, helper, options).present }

  let(:user) { create :user }
  let(:type) { nil }
  let(:changeset) do
    [
      {
        attribute_name: :field,
        label: "My field",
        new_value: "New value",
        previous_value: "Previous value",
        type:
      }
    ]
  end
  let(:presenter_double) { double(present: true) }
  let(:options) { {} }

  describe "#present" do
    context "when no changeset is present" do
      let(:changeset) { [] }

      it "returns an empty string" do
        expect(subject).to be_empty
      end
    end

    it "shows the attribute label" do
      expect(subject).to include("My field")
    end

    it "shows the new value" do
      expect(subject).to include("New value")
    end

    it "shows the previous value" do
      expect(subject).to include("Previous value")
    end

    describe "options" do
      context "when `show_previous_value?` is false" do
        let(:options) { { show_previous_value?: false } }

        it "does not show the previous value" do
          expect(subject).not_to include("Previous value")
        end
      end
    end

    describe "value types presenters" do
      context "when it's a symbol" do
        let(:type) { :percentage }

        it "finds the class from the symbol name" do
          expect(Decidim::Log::ValueTypes::PercentagePresenter)
            .to receive(:new).twice.and_return(presenter_double)
          expect(presenter_double).to receive(:present)

          subject
        end

        context "when it cannot find the class" do
          let(:type) { :foobardoe }

          it "uses the default one" do
            expect(Decidim::Log::ValueTypes::DefaultPresenter)
              .to receive(:new).twice.and_return(presenter_double)
            expect(presenter_double).to receive(:present)

            subject
          end
        end
      end

      context "when it's a String" do
        let(:type) { "Decidim::Log::ValueTypes::DatePresenter" }

        it "finds the class" do
          expect(Decidim::Log::ValueTypes::DatePresenter)
            .to receive(:new).twice.and_return(presenter_double)
          expect(presenter_double).to receive(:present)

          subject
        end

        context "when it cannot find the class" do
          let(:type) { "Decidim::Log::ValueTypes::DoesNotExist" }

          it "uses the default one" do
            expect(Decidim::Log::ValueTypes::DefaultPresenter)
              .to receive(:new).twice.and_return(presenter_double)
            expect(presenter_double).to receive(:present)

            subject
          end
        end
      end

      context "when it's nil" do
        let(:type) { nil }

        it "uses the default one" do
          expect(Decidim::Log::ValueTypes::DefaultPresenter)
            .to receive(:new).twice.and_return(presenter_double)
          expect(presenter_double).to receive(:present)

          subject
        end
      end
    end
  end
end
