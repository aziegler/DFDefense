MAIN_VOLUME = 1
function mute(group)
   for _,track in pairs(group) do
      track:setVolume(0.0)
   end
end

function unmute(group)
   for k,track in pairs(group) do
      track:setVolume(MAIN_VOLUME)
   end
end

function setPosition(groups, pos)
   for k,v in pairs(groups) do
      for _,t in pairs(v) do
         t:seek(pos, "seconds")
      end
   end
end

function loadAudio()

   local trackFiles = {
      "assets/music/voice.wav",
      "assets/music/instru.wav",
   }

   local tracks = {}

   for i,track in pairs(trackFiles) do
      local t = love.audio.newSource(track)
      tracks[track] = t
      t:play()
      t:setVolume(MAIN_VOLUME)
   end

   local groups = {
      voice = {
         tracks["assets/music/voice.wav"]
      },
      instru = {
         tracks["assets/music/instru.wav"]
      }
   }

   return groups
end

loop = 12
start = 27
tracks = {}

function audioLoad(audioConfig)
   audioGroups = loadAudio()
   for k,v in pairs(audioConfig.loops) do
      table.insert(tracks, { start = start + v.loop*loop,
                             voice = v.voice, tbs = v.tbs })
   end
   setPosition(audioGroups, audioConfig.start)

   i = 1
   affTxt =  love.graphics.newText(fonts.small, ""..i )

end

function audioUpdate()
   local voiceOn = false
   local tbs = 0

   if i > #tracks then
      return
   end

   if tracks[i].voice then
      if love.keyboard.isDown("1") then
         mute(audioGroups.voice)
      else
         unmute(audioGroups.voice)
         voiceOn = true
      end
   else
      if love.keyboard.isDown("1") then
         unmute(audioGroups.voice)
         voiceOn = true
      else
         mute(audioGroups.voice)
      end
   end

   if audioGroups.voice[1]:tell("seconds") < tracks[i].start then
      voiceOn = false
      tbs = nil
   else
      tbs = tracks[i].tbs
   end

   if audioGroups.voice[1]:tell("seconds") >= tracks[i].start+loop then
      if not love.keyboard.isDown("space") then
         i = i + 1
         if i > #tracks then
            -- i = 1
            return false, nil
         end
         affTxt =  love.graphics.newText(fonts.small, ""..i )
      end
      setPosition(audioGroups, tracks[i].start)

   end

   return voiceOn, tbs
end

function audioDraw()
   local angle = (math.pi*2*(audioGroups.voice[1]:tell("seconds")-tracks[i].start)/loop) - math.pi/2

   local r = 100
   local x = r+5
   local y = r+5


   love.graphics.setLineWidth(3)
   love.graphics.setColor(100, 100, 100)
   love.graphics.line(x, y, x, y-r)

   if love.keyboard.isDown("space") then
      love.graphics.setColor(255, 0, 0)
   else
      love.graphics.setColor(255, 255, 255)
   end

   love.graphics.circle("line", x, y, r, 100)

   love.graphics.line(x, y,
                      x + r*math.cos(angle),
                      y + r*math.sin(angle))

   love.graphics.draw(affTxt, x-r,y-r)
end
