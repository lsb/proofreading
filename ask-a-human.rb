require 'rest-client'
require 'json'

AskEndpoint = "127.0.0.1:4567/ask" # "http://vivam.us/human/ask"

def ask_human_choose_one(instructions, question, choices, gold_standards = [], extras={})
  return choices.first if choices.size < 2
  params = {instructions: instructions, question: JSON.dump([question] + choices), type: "radio", gold_standards: JSON.dump(gold_standards)}.merge(extras)
  RestClient.put(AskEndpoint, params)
  actual_response = lambda {
    begin
      RestClient.post(AskEndpoint, params)
    rescue RestClient::ResourceNotFound
      nil
    end
  }
  sleep(10) until actual_response[]
  JSON.parse(actual_response[])
end

def ask_human_text(instructions, question, default="", gold_standards = [], extras = {})
  params = {instructions: instructions, question: JSON.dump([question, default]), type: "text", gold_standards: JSON.dump(gold_standards)}.merge(extras)
  RestClient.put(AskEndpoint, params)
  actual_response = lambda {
    begin
      RestClient.post(AskEndpoint, params)
    rescue RestClient::ResourceNotFound
      nil
    end
  }
  sleep(10) until actual_response[]
  JSON.parse(actual_response[])
end
