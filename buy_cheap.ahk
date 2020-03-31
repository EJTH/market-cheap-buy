#include <Vis2>
#MaxThreadsPerHotkey 2
; Refresh 1840, 120
; Expire label 1480 160 (0x0B1029)
; buy first 1700 180
; buy all 1180 480
; check list update 1680 160

buyPrice = 12000
buyAll = 0
maxCount = 10

^e::
  settings()
return

^q::
  stop = 1
return

^r::
  stop = 0
  bought = 0
  Loop {
    if(stop){
      return
    }

    fastRefresh()

    sleep 100
    while(!checkReadyToBuy()){
      sleep 1
    }
    price := getPrice()
    ;ToolTip %price%,0,0
    if(price <= buyPrice and price > 100){
      buyTopLine()
      ToolTip %text% (%otext%), 0, 24, 2
      bought := bought + 1
      SoundPlay, %A_WinDir%\Media\ding.wav
    }
    if(bought >= maxCount){
      return
    }
  }
return

settings(){
  global buyPrice
  global maxCount
  help = `n`nPress Ctrl+E to show settings,`nPress Ctrl+R to run,`nPress Ctrl+Q to stop
  InputBox buyPrice, Max buy price,Your max buy price %help%,,,,,,,,%buyPrice%
  buyPrice := buyPrice + 0

  InputBox maxCount, Amount,Amount to buy %help%,,,,,,,,%maxCount%
  maxCount := maxCount + 0
}


checkTopLineExpireColor(){
  PixelGetColor color, 1480, 160
  return checkColor(color, 0x0B1029)
}

checkReadyToBuy(){
  PixelGetColor, color, 1850, 146
  return checkColor(color, 0x303130) or checkColor(color, 0x2D2A20) or checkColor(color, 0x21225D) or checkColor(color, 0x373735)
}

fastRefresh(){
  MouseMove, 482, 88
  MouseClick, left
  MouseMove, 608, 426
  MouseClick, left
  sleep 20
  MouseMove 1700, 180
}

clickRefresh(){
  color = 0
  MouseMove 50, 50

  while(!checkColor(0xE1DCD1,color)){
    sleep 10
    pixelGetColor, color, 1837, 112
  }
  MouseMove, 1837, 112
  MouseClick, left
}

buyTopLine(){
  global buyAll
  MouseMove 1700, 180
  MouseClick left
  if(buyAll == 1){
    MouseMove 1180, 480
    MouseClick left
  }
  sleep 50
  Send {Y down}
  Sleep 75
  Send {Y up}
  sleep 100
  MouseMove 964, 570
  sleep 200
  Click left
}

checkColor(targetColor, color){
  tolerance := 10

  ;split target color into rgb
  tr := format("{:d}","0x" . substr(targetColor,3,2))
  tg := format("{:d}","0x" . substr(targetColor,5,2))
  tb := format("{:d}","0x" . substr(targetColor,7,2))

  ;split pixel into rgb
  pr := format("{:d}","0x" . substr(color,3,2))
  pg := format("{:d}","0x" . substr(color,5,2))
  pb := format("{:d}","0x" . substr(color,7,2))

  ;check distance
  distance := sqrt((tr-pr)**2+(tg-pg)**2+(pb-tb)**2)
  return distance<tolerance
}

getPrice(){
  global otext
  global text
  substitutes := [["^nin Pp$", "11 111"],["[ ]([0-9ova]{2})[ ]","$1O"],["^20 Pp$","20000"],["[ ][0ova]{3}","000"],["[ ][0ova]{2,3}[ ]","000"],["[ ]([0-9]{3})2$", "$1"]["^Gg ", "9"],["[ ]aap","000"],["333332$","33333"],["^11 p$","11000"],["^13 DP","13000"],["^35 sss Pp","35000"],["^9g g00P","9000"],["080[ ]","000"],["02$","0"],["[ ]2$",""],["[BaogGO%]","0"],["[s]","8"],["[li]","1"],["[sS]","5"],["[f]","7"],["[^0-9]",""]]
  otext := OCR([1255, 146,200,42], "eng")
  text := otext

  For index, value in substitutes
  {
    text := RegExReplace(text, value[1], value[2])
  }

  price := text+0.0
  if(RegExMatch(otext, "\$$") > 0){
    price := price * 123
  }
  if(RegExMatch(otext, "€$") > 0){
    price := price * 136
  }

  FileAppend `n%text% (%otext%), .\buylog.txt
  ToolTip %text% (%otext%), 0, 0, 1
  return text+0.0
}

^!b::
text := getPrice()
ToolTip %text% (%otext%), 0, 0
return

^!x::
PixelGetColor color, 1850, 146
MsgBox %color%
return

^!z::  ; Control+Alt+Z hotkey.
MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%
MsgBox The color at the current cursor position is %color%.
return
