require "./spec_helper"

class Person < RethinkDB::Model
  fields({
    name: String,
    age: Int32,
    defaults: {age: 15}
  })
end

describe Rethinkdbmodels do

  it "test connect" do
    RethinkDB::Db.setup({:host => "rethinkdb"})
    RethinkDB::Db.close
  end

  it "test save, edit, fetch and delete" do
    RethinkDB::Db.setup({:host => "rethinkdb"})
    person = Person.new(name: "Oliver", age: 21)
    person.save.should eq(person)
    person.name = "Laurent"
    person.save.should eq(person)
    Person.fetch(person.id).to_hash.should eq(person.to_hash)
    person.destroy.should be_true
    RethinkDB::Db.close
  end

end
