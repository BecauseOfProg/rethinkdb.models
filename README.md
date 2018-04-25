# rethinkdb.models

A really simple ORM (only fetch, save and destroy) for RethinkDB in Crystal

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  rethinkdbmodels:
    github: whaxion/rethinkdb.models
```

## Usage

```crystal
require "rethinkdb.models"

# Start connection to database
RethinkDB::Db.setup({:host => "rethinkdb"})

# Create Model
class Person < RethinkDB::Model
  fields({
    name: String, # name: type
    age: Int32,
    defaults: {age: 15} # defaults: {name: value}
  })
end

# Create and save Person
person = Person.new(name: "Oliver", age: 20)
person.save

# Change value of one field
person.name = "Laurent"
person.save

# Destroy
person.destroy

# Fetch a Person
Person.fetch(id)
```

## Contributing

1. Fork it ( https://github.com/whaxion/rethinkdb.models/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Whaxion](https://github.com/whaxion)  - creator, maintainer
