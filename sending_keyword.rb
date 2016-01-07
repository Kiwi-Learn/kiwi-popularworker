require_relative 'bundle/bundler/setup'
require 'aws-sdk'
require 'config_env'

array = ["apple", "apple", "banana", "apple", "happy", "QQ", "be happy", "cheer up!",
         "banana", "happy", "sunshine", "sunshine", "QQ", "apple", "happy"]
ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
sqs = Aws::SQS::Client.new()

q_url = sqs.get_queue_url(queue_name: 'searched_keyword').queue_url

array.each do |word|
  msg = word

  resp = sqs.send_message({
    queue_url: q_url, # required
    message_body: msg.to_json # required
  })

  if resp.successful?
    puts "successful, #{word}"
  else
    puts "failed, #{word}"
  end
end
