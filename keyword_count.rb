require_relative 'bundle/bundler/setup'
require 'aws-sdk'
require 'config_env'
require 'httparty'
require 'json'

ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")

sqs = Aws::SQS::Client.new()
q_url = sqs.get_queue_url(queue_name: 'searched_keyword').queue_url
poller = Aws::SQS::QueuePoller.new(q_url)

# set hash default function
count = Hash.new{|h,k| h[k] = {'keyword'=>k,'count'=>0 }}

# get msg and count
begin
  poller.poll(wait_time_seconds:nil, idle_timeout:2) do |msg|
    word =  msg.body.delete('"')

    #set default
    if count.has_key?(word)
      count[word]
    end

    count[word]['count'] += 1
  end
rescue AWS::SQS::Error::ServiceError
end

count = count.sort_by{|k,v| v['count']}.reverse.to_h
countarray = count.values
countarray.each_index do |i|
  countarray[i]['rank']=i+1
end

# print countarray
h = {'results' => countarray.to_json}
print h


# post to api server
begin
  HTTParty.post(
  'http://192.168.2.107:3000/api/v1/popularity',
  :header => {'Content-Type' => 'application/json'},
  :body => {'results' => countarray.to_json})
rescue
  puts "post error"
end
