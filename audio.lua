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
      "assets/music/La mutante 4 Acap_01.wav",
      "assets/music/kick_01-02.wav",
      "assets/music/synth_01-02.wav",
      "assets/music/SYNTHDELAY_01-02.wav",
      "assets/music/hats & percs_01-02.wav",
      "assets/music/bass_01-02.wav",
      "assets/music/BEATVERB_01-02.wav",
      "assets/music/SYNTHVERB_01-02.wav",
      "assets/music/snares_01-01.wav",
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
         tracks["assets/music/La mutante 4 Acap_01.wav"]
      },
      drums = {
         tracks["assets/music/kick_01-02.wav"],
         tracks["assets/music/hats & percs_01-02.wav"],
         tracks["assets/music/bass_01-02.wav"],
         tracks["assets/music/snares_01-01.wav"]
      },
      synths = {
         tracks["assets/music/synth_01-02.wav"],
         tracks["assets/music/SYNTHDELAY_01-02.wav"],
         tracks["assets/music/SYNTHVERB_01-02.wav"],
         tracks["assets/music/BEATVERB_01-02.wav"],
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
      table.insert(tracks, { start = start + v.loop*loop, voice = v.voice })
   end
   setPosition(audioGroups, audioConfig.start)

   i = 1
   arialFont = love.graphics.newFont("assets/arial.ttf")
   affTxt =  love.graphics.newText(arialFont, ""..i )

end

function audioUpdate()

   if tracks[i].voice then
      if love.keyboard.isDown("1") then
         mute(audioGroups.voice)
      else
         unmute(audioGroups.voice)
      end
   else
      if love.keyboard.isDown("1") then
         unmute(audioGroups.voice)
      else
         mute(audioGroups.voice)
      end
   end

   if audioGroups.voice[1]:tell("seconds") >= tracks[i].start+loop then
      if not love.keyboard.isDown("space") then
         i = i + 1
         if i > #tracks then
            i = 1
         end
         affTxt =  love.graphics.newText(arialFont, ""..i )
      end
      setPosition(audioGroups, tracks[i].start)

   end

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
