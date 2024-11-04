# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ResultForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:title) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:parent) { create(:result, component: current_component) }
    let(:parent_id) { parent.id }
    let(:start_date) { "12/3/2017" }
    let(:end_date) { "21/6/2017" }
    let(:status) { create(:status, component: current_component, key: "ongoing", name: { en: "Ongoing" }) }
    let(:status_id) { status.id }
    let(:progress) { 89 }
    let(:address) { "Carrer de Sant Joan, 123, 08001 Barcelona" }
    let(:latitude) { 41.38879 }
    let(:longitude) { 2.15899 }
    let(:taxonomies) { [] }

    let(:attributes) do
      {
        taxonomies:,
        parent_id:,
        title_en: title[:en],
        description_en: description[:en],
        start_date:,
        end_date:,
        decidim_accountability_status_id: status_id,
        progress:,
        address:,
        latitude:,
        longitude:
      }
    end

    it { is_expected.to be_valid }

    describe "taxonomies" do
      let(:component) { current_component }
      let(:participatory_space) { participatory_process }

      it_behaves_like "a taxonomizable resource"
    end

    describe "when progress is negative" do
      let(:progress) { -12 }

      it { is_expected.not_to be_valid }
    end

    describe "when progress is greater than 100" do
      let(:progress) { 999 }

      it { is_expected.not_to be_valid }
    end

    describe "when progress is between 0 and 100" do
      let(:progress) { (0..100).to_a.sample }

      it { is_expected.to be_valid }
    end

    describe "when progress is empty" do
      let(:progress) { nil }

      it { is_expected.to be_valid }
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when the parent does not exist" do
      let(:parent_id) { parent.id + 10 }

      it { is_expected.not_to be_valid }
    end

    describe "when the status does not exist" do
      let(:status_id) { status.id + 10 }

      it { is_expected.not_to be_valid }
    end

    context "with proposals" do
      subject { described_class.from_model(result).with_context(context) }

      let(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
      let!(:proposal) { create(:proposal, component: proposals_component) }

      let(:result) do
        create(
          :result,
          component: current_component,
          taxonomies:
        )
      end

      describe "#proposals" do
        before do
          result.link_resources([proposal], "included_proposals")
        end

        it "returns the available proposals in a way suitable for the form" do
          expect(subject.proposals)
            .to eq([proposal])
        end
      end

      describe "#map_model" do
        it "sets the proposal_ids correctly" do
          result.link_resources([proposal], "included_proposals")
          expect(subject.proposal_ids).to eq [proposal.id]
          expect(subject.taxonomies).to eq taxonomies
        end
      end
    end

    context "with projects" do
      let(:projects_component) { create(:component, manifest_name: :budgets, participatory_space: participatory_process) }
      let!(:project) { create(:project, component: projects_component) }

      describe "#projects" do
        it "returns the available projects in a way suitable for the form" do
          expect(subject.projects)
            .to eq([[translated(project.title), project.id]])
        end
      end

      describe "#map_model" do
        subject { described_class.from_model(result).with_context(context) }

        let(:result) do
          create(
            :result,
            component: current_component,
            taxonomies:
          )
        end

        it "sets the project_ids correctly" do
          result.link_resources([project], "included_projects")
          expect(subject.project_ids).to eq [project.id]
          expect(subject.taxonomies).to eq taxonomies
        end
      end
    end
  end
end
