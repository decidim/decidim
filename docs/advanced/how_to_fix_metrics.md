# How to fix metrics

At the request of some instances, we have analyzed the problem with the generation of metrics and looking for possible solutions.

Initially, we saw that it affected the instances deployed in the Heroku environment.

## Analyzing the decidim apps

  - There are some "orphans" records. That is, the component or the participatory space related didn't exists.
    This is because ParticpatorySpaces could be deleted, but they were not deleted correctly and there were unrelated records.
  - Also we found comments, which did not have the relation to the participatory spaces either.
  - Also observed that the peak we had of the metric "Supports" was more than 15 days without executing the job, and the day was restarted, when Redis was updated.
  - The previous peak was due to the fact that there were duplicate records of support metrics, per day and per proposal (for example). We do not know the reason why there are duplicates in heroku instances, but the assumptions are the following:
    - The sidekiq worker stays out of memory and executes when the job can be done, making the day change.
    - Taking the previous assumption into account, we can not find the relationship since the code of metrics should not create new ones if they already exist.

## Actions to do to delete orphan records
  - First of all back up the BBDD.
  - Clean orphan records, manually in console. (Meetings, Proposals, Comments, etc.) [Below there are the queries to destroy the orphan records](#delete-orphan-records)
  - Calculate manually, supports for example a process, to see which is the total Supports for that process.
  - Check if there are duplicate records for each process / proposal per day. (there is only one)
  - If there are duplicate records:
    - Option 1: Remove individually each record per day.
    - Option 2: Delete all records and recalculate them. Changelog of decidim version 0.18 has an example for participants. https://github.com/decidim/decidim/blob/0.18-stable/CHANGELOG.md#0180

## Conclusions
After do all the before actions:
  - We have seen that it affects instances displayed in other environments, such as AWS, but they work with sidekiq, no with DelayedJob.
  - By doing a search, we have seen that sidekiq can duplicate the jobs, to do prevent it there are 3 options.
    More info, can be found here https://blog.francium.tech/avoiding-duplicate-jobs-in-sidekiq-dcbb1aca1e20
    - Upgrade to Sidekiq Enterprise
    - Use sidekiq-unique-jobs library
    - Implement it yourself

## Delete orphan records
"proposals", "meetings", "accountability", "debates", "pages", "budgets", "surveys"

### Proposals
Delete proposals whose component does not have a participatory space and delete components of a proposal type that do not have a participatory space

```
Decidim::Component.where(manifest_name: "proposals").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Proposals::Proposal.where(component: c).destroy_all
    c.destroy
  end
}
```

Delete proposals that do not have a component
```
Decidim::Proposals::Proposal.find_each(batch_size: 100) { |proposal| 
  proposal.delete if proposal.component.blank?
}
````

### Meetings

Delete meetings whose component has no participatory space and delete components of meeting type that do not have a participatory space

```
Decidim::Component.where(manifest_name: "meetings").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Meetings::Meeting.where(component: c).destroy_all
    c.destroy
  end
}
```

Delete meetings that do not have a component
```
Decidim::Meetings::Meeting.find_each(batch_size: 100) { |meeting| 
  meeting.delete if meeting.component.blank?
}
````

### Debates
Delete debates that its component has no participatory space and the debate components that do not have a participatory space

```
Decidim::Component.where(manifest_name: "debates").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Debates::Debate.where(component: c).destroy_all
    c.destroy
  end
}
```

Destroy debates that do not have a component
```
Decidim::Debates::Debate.find_each(batch_size: 100) { |debate| 
  debate.delete if debate.component.blank?
}
```

### Posts

Destroy posts whose component has no participatory space and blog components that do not have a participatory space
```
Decidim::Component.where(manifest_name: "blogs").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Blogs::Post.where(component: c).destroy_all
    c.destroy
  end
}
```

Destroy posts that do not have a component
```
Decidim::Blogs::Post.find_each(batch_size: 100) { |post| 
  post.delete if post.component.blank?
}
```

### Accountability

Destroy results whose component has no participatory space and components of accountability type that do not have a participatory space

```
Decidim::Component.where(manifest_name: "accountability").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Accountability::Result.where(component: c).destroy_all
    c.destroy
  end
}
```

Destroy results that do not have a component

```
Decidim::Accountability::Result.find_each(batch_size: 100) { |result|
  result.delete if result.component.blank?
}
```

### Pages

Destroy page components that do not have a participatory space
```
Decidim::Component.where(manifest_name: "pages").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    c.destroy
  end
}
```

### Budgets

Destroy projects whose component has no participatory space and budget components that do not have a participatory space

```
Decidim::Component.where(manifest_name: "budgets").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Budgets::Project.where(component: c).destroy_all
    c.destroy
  end
}
```

Destroy results that do not have a component
```
Decidim::Budgets::Project.find_each(batch_size: 100) { |project|
  project.delete if project.component.blank?
}
```

### Surveys

```
Decidim::Component.where(manifest_name: "surveys").find_each(batch_size: 100) { |c|
  if c.participatory_space.blank?
    Decidim::Surveys::Survey.where(component: c).destroy_all
    c.destroy
  end
}
```

Destroy surveys that do not have a component
```
Decidim::Surveys::Survey.find_each(batch_size: 100) { |survey|
  survey.delete if survey.component.blank?
}
```


### Comments

```
# We look for the comments that their commentable root are of type proposals and we make a pluck of the id.

proposal_ids = Decidim::Comments::Comment.where(decidim_root_commentable_type: "Decidim::Proposals::Proposal").pluck(:decidim_root_commentable_id)

# From the previous proposals, we seek those that do not have a participatory space

proposal_ids_without_space = Decidim::Proposals::Proposal.where(id: proposal_ids).find_all{|p| p.participatory_space.blank? }.pluck(:id) 

Decidim::Comments::Comment.where(decidim_root_commentable_type: "Decidim::Proposals::Proposal", decidim_root_commentable_id: proposal_ids_without_space).destroy_all
```
