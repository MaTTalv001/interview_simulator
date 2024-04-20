# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
    def create
      auth = request.env['omniauth.auth']
      user = User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
        u.nickname = auth.info.nickname
      end
      
      session[:user_id] = user.id
      redirect_to interview_path, notice: 'ログインしました。'
    end
  
    def destroy
      session.delete(:user_id)
      redirect_to root_path, notice: 'ログアウトしました。'
    end
  end
  
  