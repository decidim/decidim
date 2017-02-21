shared_examples_for "display reference" do
  it 'displays the reference' do
    visit_feature
    expect(page).to have_css(".reference")
  end
end
