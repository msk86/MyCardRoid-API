require 'net/http'
require 'sqlite3'
require 'json'
require 'yaml'

def run
  file_name = "cards-#{Time.now.year}-#{Time.now.month}-#{Time.now.day}"
  create_cards_cdb file_name, 'zh'
end

def create_cards_cdb file, language = 'zh'

  p "Loading datas from my-card api..."
  datas_uri = URI("http://my-card.in/cards.json")
  datas = JSON.parse Net::HTTP.get datas_uri
  count = datas.length

  p "Start loading texts under #{language} from my-card api..."
  texts_uri = URI("http://my-card.in/cards_#{language}.json")
  texts = JSON.parse Net::HTTP.get texts_uri


  p "Start create #{file}.cdb under #{language}..."
  db = SQLite3::Database.new("app/public/#{language}/#{file}.cdb")
  db.execute("CREATE TABLE datas(id integer primary key, ot integer, alias integet, setcode integer, type integer, atk integer, def integer, level integer, race integer, attribute integer, category integer)")
  import_json_data db, 'datas', datas
  db.execute("CREATE TABLE texts(id integer primary key, name varchar(128), desc varchar(1024), str1 varchar(256), str2 varchar(256), str3 varchar(256), str4 varchar(256), str5 varchar(256), str6 varchar(256), str7 varchar(256), str8 varchar(256), str9 varchar(256),			 str10 varchar(256), str11 varchar(256), str12 varchar(256), str13 varchar(256), str14 varchar(256), str15 varchar(256), str16 varchar(256) )")
  import_json_data db, 'texts', texts

  p "Update config in database.yml..."
  update_database_yml file, count, language

  p "Done!"
end

def import_json_data db, table, data
  field_map = YAML::load(File.read('config/field_map.yml'))
  columns = []
  field_map[table].each do |column, json_key|
    columns << column
  end
  column_str = "(#{columns.join ', '})"
  data.each do |record|
    values = []
    columns.each do |column|
      values << "'#{record[field_map[table][column]]}'"
    end
    value_str = "(#{values.join ', '})"
    string = "INSERT INTO #{table} #{column_str} values #{value_str}"
    db.execute(string)
  end
end

def update_database_yml file, count, language
  db_config = YAML::load(File.read('config/database.yml'))
  db_config[language]['size'] = File.size "app/public/#{language}/#{file}.cdb"
  db_config[language]['count'] = count
  db_config[language]['upgrade_url'] = "#{db_config['base_url']}/#{language}/#{file}.cdb"
  File.write('config/database.yml', db_config.to_yaml)
end

run