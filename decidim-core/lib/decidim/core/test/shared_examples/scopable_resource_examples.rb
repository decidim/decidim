# frozen_string_literal: true

shared_examples_for "a scopable resource" do
  before do
    current_component.update!(settings: { scopes_enabled: true, scope_id: parent_scope.id })
  end

  context "when the scope exists" do
    it { expect(form.scope).to be_kind_of(Decidim::Scope) }
  end

  context "when the scope does not exist" do
    let(:scope_id) { 3456 }

    it { expect(form.scope).to eq(nil) }
  end

  context "when the scope is from another organization" do
    let(:scope_id) { create(:scope).id }

    it { expect(form.scope).to eq(nil) }
  end

  context "when the component has a scope" do
    context "when the scope is descendant from component scope" do
      let(:scope) { create(:scope, organization:, parent: parent_scope) }

      it { expect(form.scope).to eq(scope) }
    end

    context "when the scope is not descendant from component scope" do
      let(:another_scope) { create(:scope, organization:) }
      let(:scope) { create(:subscope, parent: another_scope) }
      let(:scope_id) { scope.id }

      it { expect(form.scope).to eq(scope) }

      it "makes the form invalid" do
        expect(form).to be_invalid
      end
    end
  end
end
