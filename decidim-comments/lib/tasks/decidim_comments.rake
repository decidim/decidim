# frozen_string_literal: true

namespace :decidim_comments do
  desc "Adds participatory_process_id to comments if they are associated with a participatory process"
  task update_participatory_process_in_comments: :environment do
    Decidim::Comments::Comment.find_each do |c|
      c.participatory_space = if c.root_commentable.is_a?(Decidim::Participable)
                                c.root_commentable
                              else
                                c.commentable.try(:participatory_space)
                              end
      c.save(validate: false)
    end
  end
end
