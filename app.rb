require "sinatra"
require "gschool_database_connection"
require "rack-flash"
require_relative "models/user"
require_relative "models/fish"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  get "/" do
    user = current_user

    if current_user
      users = User.all

      @user = User.find(current_user.id)
      fish = @user.fishes

      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do

    @user = User.create(username: params[:username], password: params[:password])

    if @user.valid?
      @user.save
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      flash[:notice] = @user.errors.full_messages
      erb :register
    end

  end


  post "/sessions" do
    if validate_authentication_params
      user = authenticate_user

      if user != nil
        session[:user_id] = user.id
      else
        flash[:notice] = "Username/password is invalid"
      end
    end

    redirect "/"
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  delete "/users/:id" do

    @user = User.find(params[:id])
    @user.destroy

    redirect "/"
  end

  get "/fish/new" do
    erb :"fish/new"
  end

  get "/fish/:id" do
    fish = Fish.find(params[:id])
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do

    @fish = Fish.create(name: params[:name], wikipedia_page: params[:wikipedia_page], user_id: current_user.id )

    if @fish.valid?
      @fish.save
      flash[:notice] = "Fish Created"
      redirect "/"
    else
      flash[:notice] = @fish.errors.full_messages
      erb :"fish/new"
    end
  end

  private

  def validate_authentication_params
    if params[:username] != "" && params[:password] != ""
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def authenticate_user
    User.where(username: params[:username], password: params[:password]).first
  end

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    else
      nil
    end
  end
end
