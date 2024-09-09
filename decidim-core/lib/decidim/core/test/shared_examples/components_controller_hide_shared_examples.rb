# frozen_string_literal: true

shared_examples_for "a components controller to hide" do |params|
  describe "PUT hide" do
    it "hides the components" do
      put :hide, params: { "#{params[:slug_attribute]}": space.slug, id: component.id }

      expect(component.reload.visible).to eq(false)
    end
  end
end
