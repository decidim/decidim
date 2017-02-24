shared_examples_for "display reference" do
  it 'displays the reference' do
    visit_feature

    within ".reference" do
      expect(page).to have_content(resource.reference)
    end
  end
end
