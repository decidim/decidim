# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Import::ProposalCreator do
  subject { described_class.new(data, context) }

  let!(:moment) { Time.current }
  let(:data) do
    {
      id: 1337,
      "id" => "101",
      category:,
      scope:,
      :"title/en" => Faker::Lorem.sentence,
      :"body/en" => Faker::Lorem.paragraph(sentence_count: 3),
      address: "#{Faker::Address.street_name}, #{Faker::Address.city}",
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      component:,
      published_at: moment
    }
  end
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:user) { create(:user, organization:) }
  let(:context) do
    {
      current_organization: organization,
      current_user: user,
      current_component: component,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create :participatory_process, organization: }
  let(:component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
  let(:scope) { create :scope, organization: }
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
      # rubocop:disable Style/HashSyntax
      expect(subject.resource_attributes).to eq(
        :"title/en" => data[:"title/en"],
        :"body/en" => data[:"body/en"],
        category: data[:category],
        scope: data[:scope],
        address: data[:address],
        latitude: data[:latitude],
        longitude: data[:longitude],
        component: data[:component],
        published_at: data[:published_at]
      )
      # rubocop:enable Style/HashSyntax
    end
  end

  describe "#produce" do
    it "makes a new proposal" do
      record = subject.produce

      expect(record).to be_a(Decidim::Proposals::Proposal)
      expect(record.category).to eq(category)
      expect(record.scope).to eq(scope)
      expect(record.title["en"]).to eq(data[:"title/en"])
      expect(record.body["en"]).to eq(data[:"body/en"])
      expect(record.address).to eq(data[:address])
      expect(record.latitude).to eq(data[:latitude])
      expect(record.longitude).to eq(data[:longitude])
      expect(record.published_at).to be >= (moment)
    end
  end

  describe "#finish!" do
    it "saves the proposal" do
      record = subject.produce
      subject.finish!
      expect(record.new_record?).to be(false)
    end

    it "creates admin log" do
      record = subject.produce
      expect { subject.finish! }.to change(Decidim::ActionLog, :count).by(1)
      expect(Decidim::ActionLog.last.user).to eq(user)
      expect(Decidim::ActionLog.last.resource).to eq(record)
      expect(Decidim::ActionLog.last.visibility).to eq("admin-only")
    end
  end
end
