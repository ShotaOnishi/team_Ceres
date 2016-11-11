require "require_all"
require_all "public"

class ImageInfoMessage
  def initialize(client)
    @client = client
  end
  def update(changed_callback)
    require "rmagick"
    require "carrierwave"
    require 'carrierwave/orm/activerecord'

    event = changed_callback.event
    if Message.is_postback?(event)
    elsif Message.is_message?(event)
      id = event.message["id"]
      response = @client.get_message_content(id)
      tf = File.open("/tmp/#{SecureRandom.uuid}.jpg", "w+b")
      tf.write(response.body)
      # tf = Tempfile.open("content")
      # tf.write(response.body)

      img = Magick::ImageList.new(tf.path)
      new_img = img.blur_image(20.0, 10.0)
      font = "public/fonts/Kazesawa-Bold.ttf"
      draw = Magick::Draw.new
      draw.annotate(new_img, 0, 0, 5, 5, 'ぼかしたら\nちょっと\nおしゃれ') do
        self.font      = font
        self.fill      = 'blue'
        self.stroke    = 'white'
        self.stroke_width = 4
        self.pointsize = 200
        self.gravity   = Magick::NorthWestGravity
      end
      draw.annotate(new_img, 0, 0, 5, 5, 'ぼかしたら\nちょっと\nおしゃれ') do
        self.font      = font
        self.fill      = 'blue'
        self.stroke    = 'transparent'
        self.pointsize = 200
        self.gravity   = Magick::NorthWestGravity
      end
      new_img.write(tf.path)
      new_img.destroy!
      #pixels = img.get_pixels(0, 0, img.columns, img.rows)
      #filesize = img.filesize
      photo = Photo.create(:file => tf,
       :comment =>"aaa"
       )
      Message.reply(event, output(id, photo))
      # p pixels[0].red
    end
  end

  def output(id, photo)
    [
      {
        type: "text",
        text: "画像情報を取得しました"
      },
      {
        type: "text",
        text: "id = #{id}"
      },
      {
        type: "image",
        :originalContentUrl => photo.file.standard.url.sub!(/http:/, "https:"),
        :previewImageUrl => photo.file.thumbnail.url.sub!(/http:/, "https:")
      }

      ]
    end

    # def get_user_local_bot_reply(word)
    #   response = RestClient.get 'https://chatbot-api.userlocal.jp/api/name', { params: { key: ENV['USR_LOCAL_API_KEY'], name: word} }
    #   response_json = JSON.parse(response)
    #   response_json["result"]["nickname"][rand(10)]
    # end
  end