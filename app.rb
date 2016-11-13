require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'
require 'json'
require 'rest-client'
require 'active_record'
require 'pg'
require 'require_all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'uri'
# require 'date'
require_all 'model'
require_all 'module'
include Line

# require 'dotenv'
# Dotenv.load

# Load DB filesDB
configure :production do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end

configure :development do
  ActiveRecord::Base.configurations = YAML.load_file('database.yml')
  ActiveRecord::Base.establish_connection(:development)
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/' do
#   content_type :json, :charset => 'utf-8'
#   menus = Menu.order("created_at DESC").limit(2)
#   menus.to_json(:root => false)
@menus = Menu.all
erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  Menu.create(:name => params[:name],
    :price => params[:price],
    :picture => params[:picture],
    :category => params[:category],
    :detall => params[:detail]
    )
  redirect '/'
end


get '/delete/:id' do
  @menu = Menu.find(params[:id])
  erb :delete
end

post '/delete/:id' do
  if params.has_key?("ok")
    menu = Menu.find(params[:id])
    menu.destroy
    redirect '/'
  else
    redirect '/'
  end
end

post '/callback' do
  body = request.body.read
  # p body
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
  #p "aaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  p events
  #p "bbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  message_type = nil
  events.each { |event|
    message_type = event["message"]["type"] if event["type"] == "message"
    message_type = "postback" if event["type"] == "postback"
    #client.leave_group(group_id)
  }
  callback_observer = CallbackSubject.instance
  callback_observer.delete_observers()
  if message_type == "text" || message_type == "postback"
    # callback_observer.add_observer(WelcomeMessage.new)
    # callback_observer.add_observer(FirstTimeMessage.new)
    # callback_observer.add_observer(ShowMenuCategoryMessage.new)
    # callback_observer.add_observer(ShowMenuMessage.new)
    # callback_observer.add_observer(EntryOrExitMessage.new)
    # callback_observer.add_observer(EntryMessage.new)
    # callback_observer.add_observer(ExitMessage.new)
    # callback_observer.add_observer(CheckMessage.new)
    # callback_observer.add_observer(CheckMessageSplit.new)
    # callback_observer.add_observer(WaterMessage.new)
    # callback_observer.add_observer(LocalMessage.new)
    callback_observer.add_observer(NickNameMessage.new)
  elsif message_type == "image"
    callback_observer.add_observer(ImageInfoMessage.new(client))
  else
  end
  events.each { |event|
    callback_observer.event = event
  }

  events.each { |event|
    case event
    when Line::Bot::Event::Postback
      q_array = URI::decode_www_form(event["postback"]['data'])
      q_hash = Hash[q_array]
      message = MessageContext.new(PostbackMessage.new, q_hash)
      client.reply_message(event['replyToken'], message.output_message)
    when Line::Bot::Event::Message
        message = MessageContext.new(ResponceMessage.new, event)
        case event.type
        when Line::Bot::Event::MessageType::Text
          res = client.reply_message(event['replyToken'], message.output_message)
        when Line::Bot::Event::MessageType::Image
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        when Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        else
          p "Noevent!!!"
        end
      end
    }
  end
