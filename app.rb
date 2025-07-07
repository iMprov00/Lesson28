require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog_test.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do 

	init_db
	@db.execute 'create table if not exists "Posts" ("id" integer primary key autoincrement, "create_date" date, "content" text)'

end

get '/' do 

	@result = @db.execute 'insert into Posts order by id desc'

	erb :index

end

get '/new' do 

	erb :new

end

post '/new' do  

	@content = params[:content].to_s

	if @content.empty?
		@error = "Введите текст"
		return erb :new
	end

	@db.execute "insert into Posts (content, create_date) values (?, datetime())", [@content]

	erb "Ты ввел: #{@content}"

end
