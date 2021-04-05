class AddParticipatoryProcessId < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_comments_comments, :decidim_participatory_process,
    foreign_key: true,
    index: { name: "index_comments_on_participatory_process" }
  end
end
