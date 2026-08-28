class SessionsController < ApplicationController
  def new
  end

  def destroy
    reset_session
    @current_user = nil
    redirect_to login_path, notice: "ログアウトしました"
  end

  def create
    auth_info = request.env.fetch("omniauth.auth")
    user = User.sync_with_discord(auth_info)

    reset_session
    log_in(user)

    redirect_to user_diaries_path(user), notice: "ログインしました"
  end

  def failure
    redirect_to login_path, notice: "Discordログインが完了できませんでした"
  end

  private

  def log_in(user)
    session[:user_id] = user.id
  end
end
