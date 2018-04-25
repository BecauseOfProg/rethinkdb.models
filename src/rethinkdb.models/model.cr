module RethinkDB

  class Model

    @id : (String)?

    macro fields(fields)
      {% for k, v in fields %}
        {% if k != :defaults %}
          @{{k}} : {{v}}?
        {% end %}
      {% end %}

      def initialize(
        {% for k, v in fields %}
          {% if k != :defaults %}
            {% if fields[:defaults] && fields[:defaults][k] %}
              {{k}} = {{fields[:defaults][k]}},
            {% else %}
              {{k}} = nil,
            {% end %}
          {% end %}
        {% end %}
        id = nil
      )
        {% for k, v in fields %}
          {% if k != :defaults %}
            @{{k}} = {{k}}
          {% end %}
        {% end %}
        @id = id
        check_table
      end

      {% for k, v in fields %}
        {% if k != :defaults %}
          def {{k}}
            @{{k}}
          end

          def {{k}}=(val : {{v}})
            @{{k}} = val
          end

          def {{k}}=(val : Nil)
            @{{k}} = nil
          end
        {% end %}
      {% end %}
    end

    def to_hash
      data = {} of Symbol => (String | Int32)?
      {% for k, v in @type.instance_vars %}
        data[:{{k}}] = @{{k}}
      {% end %}
      return data
    end

    def self.fetch(id)
      table = {{@type.name}}.to_s.downcase
      response = RethinkDB.table(table).get(id).run(RethinkDB::Db.conn)
      model = self.allocate
      {% for k, v in @type.instance_vars %}
        {% if k != :defaults %}
          {% if k.type >= String %}
            model.{{k}} = response["{{k}}"].as_s?
          {% elsif k.type >= Int32 %}
            model.{{k}} = response["{{k}}"].as_i?
          {% end %}
        {% end %}
      {% end %}
      return model
    end

    def id()
      if @id
        @id
      end
    end

    def id=(id)
      unless @id
        @id = id.to_s
      end
    end

    def save()
      table = {{@type.name}}.to_s.downcase
      data = {} of Symbol => (String | Int32)?
      {% for k, v in @type.instance_vars %}
        unless %q({{k}}) == "id"
          data[:{{k}}] = @{{k}}
        end
      {% end %}
      if @id
        response = RethinkDB.table(table).get(@id).update(data).run(RethinkDB::Db.conn)
      else
        response = RethinkDB.table(table).insert(data).run(RethinkDB::Db.conn)
      end
      if response["inserted"] == 1 || response["replaced"] == 1
        if response["generated_keys"]?
          @id = response["generated_keys"][0].to_s
        end
        return self
      end
    end

    def destroy()
      if @id
        table = {{@type.name}}.to_s.downcase
        response = RethinkDB.table(table).get(@id).delete().run(RethinkDB::Db.conn)
        if response["deleted"] == 1
          @id = nil
          return true
        end
      end
      return false
    end

    private def check_table()
      unless @@table_exists
        table = {{@type.name}}.to_s.downcase
        unless RethinkDB.table_list().run(RethinkDB::Db.conn).includes?(table)
          response = RethinkDB.table_create(table).run(RethinkDB::Db.conn)
          unless response["tables_created"] == 1
            return false
          end
          @@table_exists = true
        end
      end
      return true
    end

  end

end
