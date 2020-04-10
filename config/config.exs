import Config

config :ex_dice_roller,
  cache_table: ExDiceRoller.Cache
config :nostrum,
  token: "NDY5NTE0NTEwODUyNDIzNjgx.XoTJpw.Snf3K0KfbEk-eElVqP1wLvjz_Fc", # The token of your bot as a string
  num_shards: :auto # The number of shards you want to run your bot under, or :auto.
config :logger,
  level: :debug
