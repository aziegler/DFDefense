function loadShaders()
   local pixelcodeWhite = [[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            texcolor.x = 1;
            texcolor.y = 1;
            texcolor.z = 1;
            return texcolor * color;
        }
    ]]

   local pixelcodeHallo = [[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            float diff = 0.005;
            vec4 texcolor = Texel(texture, texture_coords);
            vec2 tc;
            vec4 tcol;

            if (texcolor.w < 0.5) {
              for(int i = -10; i <= 10; i++) {
                for(int j = -10; j <= 10; j++) {
                  tc.x = texture_coords.x + i*diff;
                  tc.y = texture_coords.y + j*diff;
                  tcol = Texel(texture, tc);
                  if (tcol.w >= 0.5) {
                    texcolor.x += 1;
                    texcolor.y += 1;
                    texcolor.z += 1;
                    texcolor.w += 1;
                  }
                }
              }
              texcolor /= 20*5;
              texcolor *= color;
            }
            return texcolor;
        }
    ]]


   local vertexcode = [[
        vec4 position( mat4 transform_projection, vec4 vertex_position )
        {
            return transform_projection * vertex_position;
        }
    ]]

   shaderWhite = love.graphics.newShader(pixelcodeWhite, vertexcode)
   shaderHallo = love.graphics.newShader(pixelcodeHallo, vertexcode)

end
