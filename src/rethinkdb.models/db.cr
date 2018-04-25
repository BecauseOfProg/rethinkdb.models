require "rethinkdb"

module RethinkDB

  class Db

    @@conn : RethinkDB::Connection?

    def self.setup(opts={} of String => (String | Int32))
      @@conn = RethinkDB.connect(opts)
      if opts[:db]?
        db = opts[:db].to_s
      else
        db = "test"
      end
      unless RethinkDB.db_list().run(conn).includes?(db)
        RethinkDB.db_create(db).run(conn)
      end
    end

    def self.close()
      check
      @@conn.as(RethinkDB::Connection).close
      @@conn = nil
    end

    def self.conn()
      check
      @@conn.as(RethinkDB::Connection)
    end

    protected def self.check
      raise "Database is not initialized, please call RethinkDB::Db.setup" if @@conn.nil?
    end

  end

end
