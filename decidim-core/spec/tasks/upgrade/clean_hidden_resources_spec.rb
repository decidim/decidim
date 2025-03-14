# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:hidden_resources", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect do
        Rake::Task[:"decidim:upgrade:clean:hidden_resources"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are no hidings requests" do
    let!(:searchables) { create_list(:searchable_resource, 8) }

    it "it does not hide any resource" do
      expect { task.execute }.not_to change(Decidim::SearchableResource, :count)
    end
  end

  context "when there was a hiding request" do
    let!(:searchables) { create_list(:searchable_resource, 8, resource_type: "Decidim::Proposals") }

    it "it hides the reported resource and associated comments from search results" do
      comments = Decidim::Comments::Comment.where("decidim_root_commentable_id" => searchables.collect(&:id).sample(1))
      expect { task.execute }.to change(Decidim::SearchableResource, :count).by(-comments.size)
    end
  end
end
