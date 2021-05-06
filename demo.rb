my_user = Decidim::User.where(email: "admin@example.org")

Decidim::Gamification.reset_badges(my_user)

users = Decidim::User.all. - my_user
names = Decidim::Gamification.badges.map(&:name)
users.each { |user| names.each { |name| Decidim::Gamification.set_score(user, name.to_sym, rand(150)) } }
