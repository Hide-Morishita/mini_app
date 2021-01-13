class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  validates :nickname, :lastname, :firstname, :birthday ,presence: true
  has_one :address
  has_many :sns_credentials


  def self.from_omniauth(auth)
    #クラスメソッドにすることで、omniauth_controller.rbでfrom_omniauthを呼び出すことができる
    # binding.pry
    #binding.pryで止めたあとに引数であるauthを入力することで送られてきた情報の中身を確認することができる
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_create
    ## ログイン
    # SnsCredentialモデルにoptional: trueを付与したので、sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_createの行で、外部キーがないレコードが保存されています。
    ## ログイン
    # 送られてきた情報からproviderとuidを検索
    # first_or_createは、保存するレコードがデータベースに存在するか検索を行い、検索した条件のレコードがあればそのレコードのインスタンスを返し、なければ新しくインスタンスを保存するメソッドです。
    # sns認証したことがあればアソシエーションで取得
    # 無ければemailでユーザー検索して取得orビルド(保存はしない)
    user = User.where(email: auth.info.email).first_or_initialize(
      nickname: auth.info.name,
      email: auth.info.email,
    )
    # first_or_initializeは、whereメソッドとともに使うことで、whereで検索した条件のレコードがあればそのレコードのインスタンスを返し、なければ新しくインスタンスを作るメソッドです。(保存はしない)

    # userが登録済みであるか判断
    if user.persisted?
      sns.user = user #snsとuserの紐付けを行う
      sns.save  #snaテーブルに紐付いた情報を保存
    end
    { user: user, sns: sns } #snsに入っているsns_idをコントローラーで扱えるようにする
  end
end
