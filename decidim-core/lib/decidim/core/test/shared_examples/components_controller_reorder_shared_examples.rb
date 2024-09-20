# frozen_string_literal: true

shared_examples_for "a reorder components controller" do |params|
  describe "PUT reorder" do
    let(:other_component) do
      create(
        :component,
        manifest_name: :dummy,
        participatory_space: space
      )
    end

    it "reorders the components" do
      expect([component.id, other_component.id]).to eq(space.components.pluck(:id))

      put :reorder, params: { "#{params[:slug_attribute]}": space.slug, order_ids: [other_component.id, component.id] }

      expect([other_component.id, component.id]).to eq(space.components.pluck(:id))
    end
  end
end
