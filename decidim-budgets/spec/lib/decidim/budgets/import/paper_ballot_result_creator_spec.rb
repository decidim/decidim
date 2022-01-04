# frozen_string_literal: true

 require "spec_helper"

 describe Decidim::Budgets::Import::PaperBallotResultCreator do
   subject { described_class.new(data, context) }

   let(:project) { create(:project) }
   # rubocop:disable Style/HashSyntax
   let(:data) do
     {
       id: project.id,
       votes: votes,
     }
   end
   let(:organization) { create(:organization, available_locales: [:en]) }
   let(:user) { create(:user, organization: organization) }
   let(:context) do
     {
       current_organization: organization,
       current_user: user,
       current_component: component,
       current_participatory_space: participatory_process
     }
   end
   let(:participatory_process) { create :participatory_process, organization: organization }
   let(:component) { create :component, manifest_name: :budgets, participatory_space: participatory_process }
   let(:votes) {rand(1000) }

   describe "#resource_klass" do
     it "returns the correct class" do
       expect(described_class.resource_klass).to be(Decidim::Budgets::PaperBallotResult)
     end
   end

   describe "#resource_attributes" do
     it "returns the attributes hash" do
       expect(subject.resource_attributes).to eq(
         id: data[:id],
         votes: data[:votes]
       )
     end
   end

   describe "#produce" do
     it "creates a paper ballot result" do
       record = subject.produce

       expect(record).to be_a(Decidim::Budgets::PaperBallotResult)
       expect(record.decidim_project_id).to eq(data[:id])
       expect(record.votes).to eq(data[:votes])
     end
   end

   describe "#finish!" do
     it "saves the paper ballot result" do
       record = subject.produce
       subject.finish!
       expect(record.new_record?).to be(false)
     end

     it "creates an admin log record" do
       record = subject.produce
       subject.finish!

       log = Decidim::ActionLog.last
       expect(log.resource).to eq(record)
       expect(log.action).to eq("paper_ballot_result")
     end
   end
   # rubocop:enable Style/HashSyntax
 end
