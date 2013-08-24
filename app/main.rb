require 'rubygems'
require 'json'
require 'yaml'
require 'sinatra'

set :bind, '0.0.0.0'
set :port, 8080
set :public_folder, File.dirname(__FILE__) + '/public'

get '/upgrade.json' do
  get_version_config
end

get '/upgrade-:language.json' do
  get_version_config params[:language]
end

get '/database.json' do
  get_database_config
end

get '/database-:language.json' do
  get_database_config params[:language]
end

def get_database_config language = 'zh'
  db_config = YAML::load(File.read('config/database.yml'))
  db_config[language].to_json
end

def get_version_config language = 'zh'
  version_config = YAML::load(File.read('config/version.yml'))
  version_config[language].to_json
end


