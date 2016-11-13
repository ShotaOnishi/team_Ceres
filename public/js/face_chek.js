$(function()
{
  var id = "face-image"
  var img = new Image();

  img.onload = function() {
        //ここにコードを記述
        //プログラムの実行
        $( "#" + id ).faceDetection( {

      // プログラムが完了すると[obj]に顔に関するデータが含まれている
      complete: function (obj)
      {
        // 顔を認識できなかった(objにデータがない)場合
        if( typeof(obj)=="undefined" )
        {
          alert( "顔情報を認識できませんでした…。" ) ;
          return false ;
        }

        // 顔を認識できた場合
        else
        {
          // 人数分だけループ処理する
          for( var i=0 ; i<obj.length ; i++ )
          {
            // ラッパー要素内に、顔範囲を示すdiv要素を追加
            $( "#face-image" ).after( '<div class="face-image-border"></div>' ) ;
            $("#image_bool").after( '<div>hello!!</div>' ) ;
            // 顔範囲の場所を動的に指定
            $(".face-image-border").eq(i).css( {
              left:obj[i].x * obj[i].scaleX + "px" ,
              top:obj[i].y * obj[i].scaleY + "px" ,
              width:obj[i].width  * obj[i].scaleX + "px" ,
              height:obj[i].height * obj[i].scaleY + "px"
            } ) ;
          }
        }
      } ,

      // プログラムの実行に失敗した時の処理
      error:function(code,message)
      {
        // エラーすると原因を示すテキストを取得できるのでアラート表示する
        alert( "Error:" + message ) ;
      }
    } ) ;
      }

      img.src = $( "#" + id ).attr( 'src' ) + '?' + Math.floor( new Date().getTime() / 1000 ) ;

    }
    )