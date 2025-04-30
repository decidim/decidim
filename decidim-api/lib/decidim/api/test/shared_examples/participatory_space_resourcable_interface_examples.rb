# frozen_string_literal: true

require "spec_helper"

shared_examples_for "participatory space resourcable interface" do
  let!(:process1) { create(:participatory_process, organization: model.organization) }
  let!(:process2) { create(:participatory_process, organization: model.organization) }
  let!(:process3) { create(:participatory_process, organization: model.organization) }
  let!(:model) { create(:assembly) }

  context "when checks is has steps" do
    describe "hasSteps" do
      let(:query) { "{hasSteps}" }

      it "has the field" do
        expect(response["hasSteps"]).to be(false)
      end
    end

    describe "allows_steps" do
      let(:query) { "{allowsSteps}" }

      it "has the field" do
        expect(response["allowsSteps"]).to be(false)
      end
    end
  end

  context "when linked from the model" do
    describe "linkedParticipatorySpaces" do
      let(:query) { "{ linkedParticipatorySpaces { participatorySpace { id } } }" }

      before do
        model.link_participatory_space_resources([process1, process2], :included_participatory_processes)
      end

      it "includes the linked resources" do
        ids = response["linkedParticipatorySpaces"].map { |l| l["participatorySpace"]["id"] }
        expect(ids).to include(process1.id.to_s, process2.id.to_s)
        expect(ids).not_to include(process3.id.to_s)
      end
    end
  end

  context "when linked towards the model" do
    describe "linkedParticipatorySpaces" do
      let(:query) { "{ linkedParticipatorySpaces { participatorySpace { id } } }" }

      before do
        process1.link_participatory_space_resources(model, :included_participatory_processes)
        process2.link_participatory_space_resources(model, :included_participatory_processes)
      end

      it "includes the linked resources" do
        ids = response["linkedParticipatorySpaces"].map { |l| l["participatorySpace"]["id"] }
        expect(ids).to include(process1.id.to_s, process2.id.to_s)
        expect(ids).not_to include(process3.id.to_s)
      end
    end
  end
end
