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
	@db.execute 'create table if not exists "Comment" ("id" integer primary key autoincrement, "create_date" date, "comment" text, "post_id" integer)'

end

get '/' do 

	@result = @db.execute 'select * from Posts order by id desc'

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

	redirect to '/'

end

get '/post/:id' do 

	id = params[:id ]

	@result = @db.execute 'select * from Posts where id = ?', [id]
	@row = @result[0]

	@comments = @db.execute 'select * from Comment where post_id = ?', [id]

	erb :post

end

post '/post/:id' do  

	id = params[:id]

	content = params[:content].to_s

	if content.empty?
		@error = "Введите текст"
		return erb :new
	end

	@db.execute "insert into Comment (comment, create_date, post_id) values (?, datetime(), ?)", [content, id]

	redirect to ('/post/' + id)


end