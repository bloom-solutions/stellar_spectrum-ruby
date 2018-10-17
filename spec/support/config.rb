config = YAML.load_file(SPEC_DIR.join("config.yml")).with_indifferent_access
if payment_channel_seeds = ENV["PAYMENT_CHANNEL_SEEDS"].presence
  config[:payment_channel_seeds] = payment_channel_seeds.split(",")
end
if sender_seed = ENV["SENDER_SEED"].presence
  config[:sender_seed] = sender_seed
end
CONFIG = config
