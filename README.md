# ActiveRecordStreamer

Stream ActiveRecord results in a new database connection using an unbuffered query.

Great for huge queries with ordered results, where `find_each` is not an option.

ActiveRecordStreamer works through a single huge unbuffered query. For each 1000 models it preloads any includes and yields them back. It then loads another 1000 over and over until all rows has been read.

## Install

Add to your Gemfile and bundle:

```ruby
gem 'active_record_streamer'
```

## Usage

Use a normal query, pass it through ActiveRecordStreamer and loop over the results with `each`:

```ruby
users = User.where(something: 'something').includes(group: :users)

ActiveRecordStreamer.new(query: users).each |user|
  puts "User: #{user.inspect}"
end
```

## Contributing to active-record-streamer

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 kaspernj. See LICENSE.txt for
further details.

