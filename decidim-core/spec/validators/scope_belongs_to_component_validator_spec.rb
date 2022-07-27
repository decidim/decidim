# frozen_string_literal: true

require "spec_helper"

describe ScopeBelongsToComponentValidator do
  subject { validatable.new(scope:, component:) }

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :scope
      attribute :component

      validates :scope, scope_belongs_to_component: true
    end
  end
  let(:component) { create :component, organization: }
  let!(:parent_scope) { create(:scope, organization:) }
  let!(:organization) { create :organization }

  before do
    component.update!(settings: { scopes_enabled: true, scope_id: parent_scope.id })

    allow(validatable).to receive(:component).and_return(component)
  end

  context "when the scope is valid" do
    let!(:scope) { create(:subscope, parent: parent_scope) }

    it "validates scope_belongs_to_component" do
      expect(subject).to be_valid
    end
  end

  context "when the scope is not valid" do
    let(:another_scope) { create(:scope, organization:) }
    let(:scope) { create(:scope, organization:, parent: another_scope) }

    it { is_expected.to be_invalid }
  end
end
