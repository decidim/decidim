# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ParticipatoryProcessSerializer do
    let(:resource) { create(:participatory_process) }
    let(:subject) { described_class.new(resource) }

    describe "#serialize" do
      it "includes the participatory process data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(subject.serialize).to include(id: resource.id)
        expect(subject.serialize).to include(title: resource.title)
        expect(subject.serialize).to include(subtitle: resource.subtitle)
        expect(subject.serialize).to include(slug: resource.slug)
        expect(subject.serialize).to include(hashtag: resource.hashtag)
        expect(subject.serialize).to include(short_description: resource.short_description)
        expect(subject.serialize).to include(description: resource.description)
        expect(subject.serialize).to include(announcement: resource.announcement)
        expect(subject.serialize).to include(start_date: resource.start_date)
        expect(subject.serialize).to include(end_date: resource.end_date)
        expect(subject.serialize).to include(remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(resource).hero_image_url)
        expect(subject.serialize).to include(remote_banner_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(resource).banner_image_url)
        expect(subject.serialize).to include(developer_group: resource.developer_group)
        expect(subject.serialize).to include(local_area: resource.local_area)
        expect(subject.serialize).to include(meta_scope: resource.meta_scope)
        expect(subject.serialize).to include(participatory_scope: resource.participatory_scope)
        expect(subject.serialize).to include(participatory_structure: resource.participatory_structure)
        expect(subject.serialize).to include(target: resource.target)
        expect(subject.serialize).to include(private_space: resource.private_space)
        expect(subject.serialize).to include(promoted: resource.promoted)
        expect(subject.serialize).to include(scopes_enabled: resource.scopes_enabled)
        expect(subject.serialize).to include(show_statistics: resource.show_statistics)
      end

      context "when process has area" do
        let(:area) { create :area, organization: resource.organization }

        before do
          resource.area = area
          resource.save
        end

        it "includes the area" do
          serialized_area = subject.serialize[:area]

          expect(serialized_area).to be_a(Hash)

          expect(serialized_area).to include(id: resource.area.id)
          expect(serialized_area).to include(name: resource.area.name)
        end
      end

      context "when process has scope" do
        let(:scope) { create :scope, organization: resource.organization }

        before do
          resource.scope = scope
          resource.save
        end

        it "includes the scope" do
          serialized_scope = subject.serialize[:scope]

          expect(serialized_scope).to be_a(Hash)

          expect(serialized_scope).to include(id: resource.scope.id)
          expect(serialized_scope).to include(name: resource.scope.name)
        end
      end

      context "when process belongs to process group" do
        let(:participatory_process_group) { create :participatory_process_group, organization: resource.organization }

        before do
          resource.participatory_process_group = participatory_process_group
          resource.save
        end

        it "includes the participatory process group" do
          serialized_participatory_process_group = subject.serialize[:participatory_process_group]

          expect(serialized_participatory_process_group).to be_a(Hash)

          expect(serialized_participatory_process_group).to include(id: resource.participatory_process_group.id)
          expect(serialized_participatory_process_group).to include(name: resource.participatory_process_group.name)
          expect(serialized_participatory_process_group).to include(description: resource.participatory_process_group.description)
          expect(serialized_participatory_process_group).to include(remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupPresenter.new(resource.participatory_process_group).hero_image_url)
        end
      end

      context "when process has steps" do
        let(:step) { create :participatory_process_step }

        before do
          resource.steps << step
          resource.save
        end

        it "includes the participatory_process_steps" do
          serialized_participatory_process_steps = subject.serialize[:participatory_process_steps].first

          expect(serialized_participatory_process_steps).to be_a(Hash)

          expect(serialized_participatory_process_steps).to include(id: step.id)
          expect(serialized_participatory_process_steps).to include(title: step.title)
          expect(serialized_participatory_process_steps).to include(description: step.description)
          expect(serialized_participatory_process_steps).to include(start_date: step.start_date)
          expect(serialized_participatory_process_steps).to include(end_date: step.end_date)
          expect(serialized_participatory_process_steps).to include(cta_path: step.cta_path)
          expect(serialized_participatory_process_steps).to include(cta_text: step.cta_text)
          expect(serialized_participatory_process_steps).to include(active: step.active)
          expect(serialized_participatory_process_steps).to include(position: step.position)
        end
      end

      context "when process has categories" do
        let!(:category) { create(:category, participatory_space: resource) }

        it "includes the categories" do
          serialized_participatory_process_categories = subject.serialize[:participatory_process_categories].first
          expect(serialized_participatory_process_categories).to be_a(Hash)

          expect(serialized_participatory_process_categories).to include(id: category.id)
          expect(serialized_participatory_process_categories).to include(name: category.name)
          expect(serialized_participatory_process_categories).to include(description: category.description)
          expect(serialized_participatory_process_categories).to include(parent_id: category.parent_id)
        end

        context "when category has subcategories" do
          let!(:subcategory) { create(:subcategory, parent: category, participatory_space: resource) }

          it "includes the categories" do
            serialized_participatory_process_categories = subject.serialize[:participatory_process_categories].first

            expect(serialized_participatory_process_categories).to be_a(Hash)

            expect(serialized_participatory_process_categories).to include(id: category.id)
            expect(serialized_participatory_process_categories).to include(name: category.name)
            expect(serialized_participatory_process_categories).to include(description: category.description)
            expect(serialized_participatory_process_categories).to include(parent_id: category.parent_id)
          end
        end
      end

      # it "includes the attachments" do

      # end
    end
  end
end
