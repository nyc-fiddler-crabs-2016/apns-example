class NotificationsController < ApplicationController
  FIREBASE_URL = 'https://flickering-heat-6121.firebaseio.com/'

  def create
    firebase = Firebase::Client.new(FIREBASE_URL)
    conv_id = params[:conv_id]

    response = firebase.get('conversations/' + conv_id)

    hash = response.body
    participants = hash['participants']
    tokens = []
    participants.each do |part|
      tokens << find_user_token(part)
    end
    APNS.pem  = File.join(Rails.root, 'config', 'cert.pem')

    tokens.each { |tok| send_one_notification(tok) }
    render text:  'OK'
  end

  def find_user_token(phone_number)
    firebase = Firebase::Client.new(FIREBASE_URL)
    url = "users/#{phone_number}"
    response = firebase.get(url)
    tok = response.body["deviceToken"]
    puts tok
    return tok
  end

  def send_one_notification(token)
    puts "Sending to #{tok}"
    APNS.send_notification(token,
      alert:"Hello who are you? And who am I?",
      badge: 1, sound: 'default')
  end
end