# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessStepForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:description) do
          {
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          }
        end
        let(:start_date) { nil }
        let(:end_date) { nil }
        let(:cta_path) { nil }
        let(:attributes) do
          {
            "participatory_process_step" => {
              "cta_path" => cta_path,
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "description_en" => description[:en],
              "description_es" => description[:es],
              "description_ca" => description[:ca],
              "start_date" => start_date,
              "end_date" => end_date
            }
          }
        end
        let(:organization) { build(:organization) }

        describe "dates" do
          context "when the dates are set" do
            let(:start_date) { "22/01/2016" }
            let(:end_date) { "13/10/2017" }

            it "returns them" do
              expect(subject.start_date).to eq(Date.new(2016, 1, 22))
              expect(subject.end_date).to eq(Date.new(2017, 10, 13))
            end
          end

          context "when no dates" do
            it "returns nil" do
              expect(subject.start_date).to be_nil
              expect(subject.end_date).to be_nil
            end
          end
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when cta_path is a full URL" do
          let(:cta_path) { "http://example.org" }

          it { is_expected.not_to be_valid }
        end

        context "when cta_path is a valid path" do
          let(:cta_path) { "processes/my-process/" }

          it { is_expected.to be_valid }
        end

        context "when default language in title is missing" do
          let(:title) do
            {
              ca: "Títol"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when the start_date is later than end_date" do
          let(:start_date) { 1.month.from_now }
          let(:end_date) { 2.months.ago }

          it { is_expected.to be_invalid }

          it "has an error" do
            subject.valid?

            expect(subject.errors).not_to be_empty
            expect(subject.errors[:end_date]).not_to be_empty
            expect(subject.errors[:start_date]).not_to be_empty
          end
        end

        context "when start_date is present" do
          let(:start_date) { 1.month.from_now }

          it { is_expected.to be_valid }
        end

        context "when end_date is present" do
          let(:end_date) { 2.months.ago }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
