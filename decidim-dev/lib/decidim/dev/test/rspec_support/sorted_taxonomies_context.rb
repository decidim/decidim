# frozen_string_literal: true

shared_context "sorted taxonomies" do
  # Ensures that the taxonomies are returned in the same order as they were
  # created by FactoryBot. This can be important for some specs that run
  # comparisons for newly loaded records against the records created through
  # FactoryBot's `create_list`.
  #
  # To find examples:
  # grep -rl --include=\*.rb 'create_list[( ]:taxonomy.*, :with_parent' **/spec | xargs grep -l '\.taxonomies'
  #
  # Note that this includes only files of the set that have calls to the
  # `.taxonomies` method indicating that these are expecting the specified
  # order. Please check through each file individually to see if this is the
  # case.
  around do |example|
    original_scopes = Decidim::Taxonomy.default_scopes
    Decidim::Taxonomy.default_scopes = [
      ActiveRecord::Scoping::DefaultScope.new(-> { order(:weight).order(:id) })
    ]
    example.run
    Decidim::Taxonomy.default_scopes = original_scopes
  end
end
