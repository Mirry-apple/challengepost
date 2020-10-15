require 'bundler/setup'
Bundler.require

require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require 'dotenv/load'

require 'open-uri'
require 'json'
require 'net/http'

enable :sessions

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
  @tags = Tag.all
end

helpers do
  def current_user
    User.find_by(id: session[:user_id])
  end
end

get '/' do
  @posts = Post.all
  @contents = Comment.all
  @tags = Tag.all
  erb :index
end

post '/comment' do
  Comment.find_or_create_by(
    content: params[:content],
    post_id: params[:post_id],
    user_id: session[:user_id]
  )
  redirect '/'
end

post '/like' do
  Like.find_or_create_by(
    post_id: params[:post_id],
    user_id: session[:user_id]
  )
  redirect '/home'
end

get '/home' do
  erb :home
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(name: params[:name])
  session[:user_id] = user.id if user&.authenticate(params[:password])
  if !current_user.nil?
    redirect '/'
  else
    redirect '/'
  end
  session[:user_id] = user.id if user.persisted?
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  img_url = ''
  if params[:file]
    img = params[:file]
    tempfile = img[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path)
    img_url = upload['url']
  end
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    description: params[:description],
    icon_url: img_url
  )
  session[:user_id] = user.id if user.persisted?
  if !current_user.nil?
    redirect '/'
  else
    redirect '/'
  end
end

get '/signout' do
  session[:user_id] = nil
  redirect '/'
end

get '/new_post' do
  @posts = current_user.posts
  erb :new
end

post '/posts/:id/delete' do
  post = Post.find(params[:id])
  post.destroy
  redirect '/home'
end

get '/posts/:id/edit' do
  @post = Post.find_by(id: params[:id])
  @tag = Tag.find_by(id: params[:id])
  erb :edit
end

post '/posts/:id' do
  post = Post.find(params[:id])
  tag = Tag.find(params[:id])
  post.body = params[:body]
  tag.tag_name = params[:tag_name]
  post.save
  tag.save
  redirect '/home'
end

post '/posts' do
  ActiveRecord::Base.transaction do
    post = Post.create!(
      user_id: session[:user_id],
      body: params[:body]
    )
    tag = Tag.find_or_create_by(
      tag_name: params[:tag_name]
    )
    Posttag.create!(
      post_id: post.id,
      tag_id: tag.id
    )
  end
  if !current_user.nil?
    redirect '/my_posts'
  else
    redirect '/'
  end
rescue StandardError => e
  redirect '/new_post'
end

get '/my_posts' do
  @posts = current_user.posts
  @tags = Tag.all
  erb :home
end

get '/myfavorite/:id' do
  post_id = Post.find(params[:id])
  user_ids = Like.where(post_id: post_id).pluck(:user_id)
  # => ["1,", "4", "5"]いいねしたユーザーのIDを取ってこれる
  @users = User.where(id: user_ids)
  # Post model
  # def liked_users end
  #   Post.liked_users
  # end
  # これを書くのが本当はスマート
  erb :likeuser
end

# post '/search' do
#   redirect '/search/:id'
# end

get '/search' do
  # @post = Post.find(params[:id])
  # @tag = Tag.find(params[:id])
  @posts = Post.all
  @contents = Comment.all
  @tags = Tag.all
  erb :search
  # redirect '/search'
end

get '/layout' do
  @tag = Tag.find(params[:id])
end

get '/search/:id' do
  @post = Post.all
  @tag = Tag.find(params[:id])
  erb :search
  # redirect '/search'
end

# post_id = Post.find(params[:id])
# tag_ids = Tag.where(post_id: post_id).pluck(:tag_id)
# @tags = Tag.where(id: tag_ids)
