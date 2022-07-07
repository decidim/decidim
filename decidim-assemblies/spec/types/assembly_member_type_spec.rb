# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Assemblies
    describe AssemblyMemberType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:assembly_member) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "fullName" do
        let(:query) { "{ fullName }" }

        it "returns the fullName field" do
          expect(response["fullName"]).to eq(model.full_name)
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns the position field" do
          expect(response["position"]).to eq(model.position)
        end
      end

      describe "user" do
        let(:query) { "{ user { name } }" }

        it "returns the user field" do
          expect(response["user"]).to be_nil
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the assembly member was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the assembly member was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the assembly member weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "gender" do
        let(:query) { "{ gender }" }

        it "returns the assembly member gender" do
          expect(response["gender"]).to eq(model.gender)
        end
      end

      describe "birthplace" do
        let(:query) { "{ birthplace }" }

        it "returns the assembly member birthplace" do
          expect(response["birthplace"]).to eq(model.birthplace)
        end
      end

      describe "designationDate" do
        let(:query) { "{ designationDate }" }

        it "returns the assembly member designationDate" do
          expect(response["designationDate"]).to eq(model.designation_date.to_date.iso8601)
        end
      end

      describe "positionOther" do
        let(:query) { "{ positionOther }" }

        it "returns the assembly member positionOther" do
          expect(response["positionOther"]).to eq(model.position_other)
        end
      end

      describe "ceasedDate" do
        let(:query) { "{ ceasedDate }" }

        it "returns the assembly member ceasedDate" do
          expect(response["ceasedDate"]).to be_nil
        end
      end
    end
  end
end
