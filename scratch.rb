require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'discourse_api'
require 'pry'

before do
  @client = DiscourseApi::Client.new("http://localhost:3000")
  @client.api_key = '024380a7edae6c74473a21d56831be4c329f90fc32fc9c1c0693d5a260244513'
  @client.api_username = 'system'
  @host = "http://localhost:3000"

end

get '/' do
  erb :index
end

get '/category-topic-authors/:category_slug' do
  category_topics = @client.category_latest_topics(category_slug: params['category_slug'])
  category_topic_authors = []

  category_topics.each do |category_topic|
    topic_id = category_topic['id']
    topic_title = category_topic['title']
    topic = @client.topic(topic_id)
    created_by = topic['details']['created_by']['username']
    user = @client.user(created_by)
    puts "***USER***"
    Pry::ColorPrinter.pp(user)
    category_topic_authors.push({title: topic_title, created_by: created_by})
  end

  erb :category_topics, :locals => {:category_topic_authors => category_topic_authors}
end

__END__

@@ layout
<html>
<head><title>Discourse Ruby API Gem</title></head>
<body>
<%= yield %>
</body>
</html>

@@ index
<h1>Understanding the Discourse Ruby API Gem</h1>

@@ category_topics
<h1>Category Topic Titles and Authors</h1>
<% category_topic_authors.each do |topic| %>
<h2><%= topic[:title] %></h2>
<p>Created By:</p>
<p><%= topic[:created_by] %></p>
<% end %>
