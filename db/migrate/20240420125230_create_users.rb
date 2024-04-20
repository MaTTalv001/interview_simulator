class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :nickname, null: false
      # t.string :token # 安全な保管方法を考慮する

      t.timestamps
    end
    add_index :users, [:uid, :provider], unique: true # ユニークインデックスを追加
  end
end
