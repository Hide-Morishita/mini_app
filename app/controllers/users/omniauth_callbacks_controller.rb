# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  def facebook
    authorization
  end
  
  def google_oauth2
    authorization
  end

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  private

  def authorization
    #OmniAuthによってFacebookから取得されたすべての情報は、request.env["omniauth.auth"]でハッシュとして入手できます
    sns_info = User.from_omniauth(request.env["omniauth.auth"])
    @user = sns_info[:user] #emailとnicknameの情報を持たせる。:userはモデルに記述しているuser

    if @user.persisted? # persistedで保存済みかどうかをチェック
      #ユーザー情報が登録済みなので、新規登録ではなくログイン処理を行う
      sign_in_and_redirect @user, event: :authentication
    else #ユーザー情報が未登録なので、新規登録画面へ遷移する
      @sns_id = sns_info[:sns].id #ビューで判断させるために定義しておく
      render template: 'devise/registrations/new'
    end
  end

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
