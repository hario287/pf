# frozen_string_literal: true

class Public::SessionsController < Devise::SessionsController
 before_action :user_state, only: [:create]

def guest_sign_in
  user = User.guest
  sign_in user
  redirect_to user_path(user), notice: 'ゲストユーザーでログインしました。'
end

def after_sign_in_path_for(resource)
  user_path(current_user)
end

protected
# 退会しているかを判断するメソッド
# ユーザーの論理削除
def user_state
  @user = User.find_by(email: params[:user][:email])
  return if !@user
  if @user.valid_password?(params[:user][:password]) && (@user.is_deleted == true)
    flash[:notice] = "退会済みです。再度ご登録をお願いします。"
    redirect_to new_user_registration_path
  end
end
end
