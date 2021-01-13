# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @user = User.new
  end

  # POST /resource
  def create
    ## sns認証(password自動生成)
    if params[:sns_auth] == 'true'  #params[:sns_auth]を取得した時
      pass = Devise.friendly_token  #Devise.friendly_tokenでpassword自動生成
      params[:user][:password] = pass
      params[:user][:password_confirmation] = pass
    end
    ## sns認証

    ## wizard
    @user = User.new(sign_up_params)
      unless @user.valid?   #バリデーションの結果がfalseだったらnewへ戻る
        render :new and return
      end
    session["devise.regist_data"] = {user: @user.attributes} #attributesメソッドを使うことで@userの情報を整形することができる、正しい型に直す
    # binding.pry
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    # binding.pry
    @address = @user.build_address  #userに紐付いたaddressモデルのインスタンスを生成
    render :new_address
    ## wizard
  end

  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(address_params)
      unless @address.valid? #条件式の返り値がfalseの場合、new_addressのビューが表示される
        render :new_address and return  #and returnがない場合はその後の記述も読み込まれてしまい、保存までされてしまう
      end
    @user.build_address(@address.attributes)
    @user.save
    session["devise.regist_data"]["user"].clear #clearメソッドを用いて明示的にsessionを削除
    sign_in(:user, @user) #sign_inメソッドを利用してログイン作業ができるようにする
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  private

  def address_params
    params.require(:address).permit(:postal_code, :address)
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
