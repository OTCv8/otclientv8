function init()
  -- add manually your shaders from /data/shaders
  g_shaders.createOutfitShader("default", "/shaders/outfit_default_vertex", "/shaders/outfit_default_fragment")

--[[  g_shaders.createOutfitShader("stars", "/shaders/outfit_stars_vertex", "/shaders/outfit_stars_fragment")
  g_shaders.addTexture("stars", "/shaders/stars.png")

  g_shaders.createOutfitShader("gold", "/shaders/outfit_gold_vertex", "/shaders/outfit_gold_fragment")
  g_shaders.addTexture("gold", "/data/shaders/gold.png")
  
  g_shaders.createOutfitShader("rainbow", "/shaders/outfit_rainbow_vertex", "/shaders/outfit_rainbow_fragment")
  g_shaders.addTexture("rainbow", "/shaders/rainbow.png")  

  g_shaders.createOutfitShader("line", "/shaders/outfit_line_vertex", "/shaders/outfit_line_fragment")
  
  g_shaders.createOutfitShader("outline", "/shaders/outfit_outline_vertex", "/shaders/outfit_outline_fragment") ]]--
end

function terminate()
end
