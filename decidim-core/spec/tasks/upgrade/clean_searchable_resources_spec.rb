# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:searchable_resources", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect do
        Rake::Task[:"decidim:upgrade:clean:searchable_resources"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let!(:searchables) { create_list(:searchable_resource, 8, created_at: 2.days.ago) }

    it "avoid removing entries" do
      expect { task.execute }.not_to change(Decidim::SearchableResource, :count)
    end
  end

  context "when there are errors" do
    let!(:searchables) { create_list(:searchable_resource, 8, created_at: 2.days.ago) }
    let!(:invalid_entries) { searchables.collect(&:id).sample(4) }

    context "when missing space manifests" do
      it "removes entries" do
        Decidim::SearchableResource.where(id: invalid_entries).update_all(decidim_participatory_space_type: "Decidim::Dev::MissingSpace") # rubocop:disable Rails/SkipsModelValidations

        expect(Decidim::SearchableResource.count).to eq(56)

        expect { task.execute }.to change(Decidim::SearchableResource, :count).by(-invalid_entries.size)

        expect(Decidim::SearchableResource.where(id: invalid_entries).length).to eq(0)
      end
    end

    context "when missing component manifests" do
      it "removes entries" do
        Decidim::SearchableResource.where(id: invalid_entries).each do |a|
          a.resource.component.destroy!
        end

        expect(Decidim::SearchableResource.count).to eq(56)

        expect { task.execute }.to change(Decidim::SearchableResource, :count).by(-invalid_entries.size * 4)

        expect(Decidim::SearchableResource.where(id: invalid_entries).length).to eq(0)
      end
    end

    context "when missing resource manifests" do
      it "removes entries" do
        Decidim::SearchableResource.where(id: invalid_entries).update_all(resource_type: "Decidim::Dev::MissingResource") # rubocop:disable Rails/SkipsModelValidations

        expect(Decidim::SearchableResource.count).to eq(56)

        expect { task.execute }.to change(Decidim::SearchableResource, :count).by(-invalid_entries.size)

        expect(Decidim::SearchableResource.where(id: invalid_entries).length).to eq(0)
      end
    end
  end
end
