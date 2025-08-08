# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:follows", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect { task.execute }.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let!(:follows) { create_list(:follow, 8, created_at: 2.days.ago) }

    it "avoid removing entries" do
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end

  context "when there are errors" do
    let!(:follows) { create_list(:follow, 8, created_at: 2.days.ago) }
    let!(:invalid_entries) { follows.collect(&:id).sample(4) }

    context "when missing manifests" do
      context "when missing resource types" do
        it "removes entries" do
          Decidim::Follow.where(id: invalid_entries).update_all(decidim_followable_type: "Decidim::Dev::MissingResource") # rubocop:disable Rails/SkipsModelValidations

          expect(Decidim::Follow.count).to eq(8)

          expect { task.execute }.to change(Decidim::Follow, :count).by(-invalid_entries.size)

          expect(Decidim::Follow.where(id: invalid_entries).length).to eq(0)
        end
      end

      context "when the component is missing" do
        it "removes entries" do
          Decidim::Follow.where(id: invalid_entries).each do |a|
            a.followable.component.destroy!
          end

          expect(Decidim::Follow.count).to eq(8)

          expect { task.execute }.to change(Decidim::Follow, :count).by(-invalid_entries.size)

          expect(Decidim::Follow.where(id: invalid_entries).length).to eq(0)
        end
      end
    end
  end
end
