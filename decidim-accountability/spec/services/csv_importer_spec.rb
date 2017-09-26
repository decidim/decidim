# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::CSVImporter do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:status_1) { create :status, feature: current_feature, progress: nil }
  let!(:status_2) { create :status, feature: current_feature, progress: 17 }
  let!(:result) { create :result, scope: scope, feature: current_feature, id: 123 }
  let!(:ext_result) { create :result, scope: scope, feature: current_feature, external_id: "existing_external_id" }
  let!(:proposal_feature) do
    create(:feature, manifest_name: "proposals", participatory_space: participatory_process)
  end
  let!(:proposals) do
    create_list(
      :proposal,
      5,
      feature: proposal_feature
    )
  end

  describe "import!" do
    context "csv file with valid data" do
      before(:each) do
        csv_file_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "valid.csv"))
        importer = Decidim::Accountability::CSVImporter.new(current_feature, csv_file_path)
        @errors = importer.import!
      end

      it "returns empty errors" do
        expect(@errors).to be_empty
      end

      it "updates existing result (with result_id)" do
        result = Decidim::Accountability::Result.find_by(external_id: "ext_id_1")

        expect(result).to be_present
        expect(result.category).to be_present
        expect(result.scope).to be_present
        expect(result.parent).to_not be_present
        expect(result.external_id).to eq("ext_id_1")
        expect(result.start_date).to eq(Date.new(2017,5,20))
        expect(result.end_date).to eq(Date.new(2017,6,30))
        expect(result.progress).to eq(40) #mean value of children's progress
        expect(result.title).to eq("ca" => "Salari bàsic de referència", "es" => "Salario básico de referencia", "en" => "Basic reference salary")
        expect(result.description).to eq("ca"=>"Description in Catalan", "en"=>"Description in English", "es"=>"Description in English")
      end

      it "creates new child result" do
        result = Decidim::Accountability::Result.find_by(external_id: "ext_id_2")

        expect(result).to be_present
        expect(result.category).to_not be_present
        expect(result.scope).to_not be_present
        expect(result.parent).to be_present
        expect(result.parent_id).to eq(123)
        expect(result.start_date).to eq(Date.new(2017,6,23))
        expect(result.end_date).to eq(Date.new(2017,7,30))
        expect(result.progress).to eq(40)
        expect(result.title).to eq("ca"=>"Child title in Catalan", "en"=>"Child title in English", "es"=>"Child title in English")
        expect(result.description).to eq("ca"=>"Description in Catalan", "en"=>"Description in English", "es"=>"Description in Spanish")
      end

      it "creates new top level result" do
        result = Decidim::Accountability::Result.find_by(external_id: "ext_id_3")

        expect(result).to be_present
        expect(result.scope).to be_present
        expect(result.decidim_scope_id).to eq(1)
        expect(result.category).to be_present
        expect(result.category.id).to eq(1)
        expect(result.start_date).to eq(Date.new(2017,6,23))
        expect(result.end_date).to eq(Date.new(2017,7,30))
        expect(result.status).to be_present
        expect(result.decidim_accountability_status_id).to eq(1)
        expect(result.progress).to eq(20) #mean value of children's progress
        expect(result.title).to eq("ca"=>"Title in Catalan", "en"=>"Title in English", "es"=>"Title in Spanish")
        expect(result.description).to eq("ca"=>"Description in Catalan", "en"=>"Description in English", "es"=>"Description in Spanish")
      end

      it "updates existing result (with external_id)" do
        result = Decidim::Accountability::Result.find_by(external_id: "existing_external_id")

        expect(result).to be_present
        expect(result.category).to be_present
        expect(result.scope).to be_present
        expect(result.parent).to_not be_present
        expect(result.start_date).to eq(Date.new(2017,6,28))
        expect(result.end_date).to eq(Date.new(2017,8,30))
        expect(result.status).to be_present
        expect(result.decidim_accountability_status_id).to eq(2)
        expect(result.progress).to eq(17)
        expect(result.title).to eq("ca"=>"Existing Title in Catalan", "en"=>"Existing Title in English", "es"=>"Existing Title in Spanish")
      end

      it "creates new child result with parent_external_id" do
        result = Decidim::Accountability::Result.find_by(external_id: "ext_id_child")

        expect(result).to be_present
        expect(result.category).to_not be_present
        expect(result.scope).to_not be_present
        expect(result.parent).to be_present
        expect(result.parent.external_id).to eq("ext_id_3")
        expect(result.start_date).to eq(Date.new(2017,8,28))
        expect(result.end_date).to eq(Date.new(2017,11,30))
        expect(result.progress).to eq(20)
        expect(result.title).to eq("ca"=>"Child ext title in Catalan", "en"=>"Child ext title in English", "es"=>"Child ext title in Spanish")
        expect(result.description).to eq("ca"=>"Description in Catalan", "en"=>"Description in English", "es"=>"Description in Spanish")
        expect(result.linked_resources(:proposals, "included_proposals").map(&:id).sort).to eq([1,2,4])
      end
    end

    context "csv file with invalid data" do
      it "doesn't change anything if any row is invalid" do
        expect do
          csv_file_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "invalid.csv"))
          importer = Decidim::Accountability::CSVImporter.new(current_feature, csv_file_path)
          errors = importer.import!
        end.to_not change{ Decidim::Accountability::Result.count }
      end

      context "errors" do
        before(:each) do
          csv_file_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "invalid.csv"))
          importer = Decidim::Accountability::CSVImporter.new(current_feature, csv_file_path)
          @errors = importer.import!
        end

        it "returns error when result doesn't exist" do
          expect(@errors).to include([9, ["No result found with result_id 1111"]])
        end

        it "returns error when dates are invalid" do
          expect(@errors).to include([2, ["Start date is invalid", "End date is invalid"]])
        end

        it "returns error when parent is invalid (id doesn't exist)" do
          expect(@errors).to include([5, ["Parent can't be blank"]])
        end

        it "returns error when status is invalid (id doesn't exist)" do
          expect(@errors).to include([6, ["Status can't be blank"]])
        end

        it "returns error when scope is invalid (id doesn't exist)" do
          expect(@errors).to include([8, ["Scope can't be blank"]])
        end

        it "returns error when category is invalid (id doesn't exist)" do
          expect(@errors).to include([7, ["Category can't be blank"]])
        end

        it "returns error when external_id is already taken" do
          expect(@errors).to include([10, ["External ID has already been taken"]])
        end
      end
    end
  end
end
