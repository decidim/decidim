# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalCreator do
  subject { described_class.new(data, context) }

  let!(:moment) { Time.current }
  let(:data) do
    {
      id: 1337,
      "id" => "101",
      category: category,
      scope: scope,
      title: {
        "en" => Faker::Lorem.sentence
      },
      body: {
        "en" => Faker::Lorem.paragraph(sentence_count: 3)
      },
      component: component,
      published_at: moment
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
  let(:component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_space: participatory_process }

  it "removes the IDs from the hash" do
    expect(subject.instance_variable_get(:@data)).not_to have_key(:id)
    expect(subject.instance_variable_get(:@data)).not_to have_key("id")
  end

  describe "#resource_klass" do
    it "returns the correct class" do
      expect(described_class.resource_klass).to be(Decidim::Proposals::Proposal)
    end
  end

  describe "#resource_attributes" do
    it "returns the attributes hash" do
      expect(subject.resource_attributes).to eq(
        title: data[:title],
        body: data[:body],
        category: data[:category],
        scope: data[:scope],
        component: data[:component],
        published_at: data[:published_at]
      )
    end
  end

  describe "#produce" do
    it "makes a new proposal" do
      record = subject.produce

      expect(record).to be_a(Decidim::Proposals::Proposal)
      expect(record.category).to eq(category)
      expect(record.scope).to eq(scope)
      expect(record.title).to eq(data[:title])
      expect(record.body).to eq(data[:body])
      expect(record.published_at).to be >= (moment)
    end
  end

  describe "#finish!" do
    it "saves the proposal" do
      record = subject.produce
      subject.finish!
      expect(record.new_record?).to be(false)
    end
  end
end
