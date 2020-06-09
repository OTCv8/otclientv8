function init()
  local files
  local loaded_files = {}
  local layout = g_resources:getLayout()
  
  local style_files = {}
  if layout:len() > 0 then
    loaded_files = {}
    files = g_resources.listDirectoryFiles('/layouts/' .. layout .. '/styles')
    for _,file in pairs(files) do
      if g_resources.isFileType(file, 'otui') then
        table.insert(style_files, file)
        loaded_files[file] = true
      end
    end  
  end
  
  files = g_resources.listDirectoryFiles('/data/styles')
  for _,file in pairs(files) do
    if g_resources.isFileType(file, 'otui') and not loaded_files[file] then
        table.insert(style_files, file)
    end
  end

  table.sort(style_files)
  for _,file in pairs(style_files) do
    if g_resources.isFileType(file, 'otui') then
      g_ui.importStyle('/styles/' .. file)
    end
  end

  if layout:len() > 0 then
    files = g_resources.listDirectoryFiles('/layouts/' .. layout .. '/fonts')
    loaded_files = {}
    for _,file in pairs(files) do
      if g_resources.isFileType(file, 'otfont') then
        g_fonts.importFont('/layouts/' .. layout .. '/fonts/' .. file)
        loaded_files[file] = true
      end
    end
  end

  files = g_resources.listDirectoryFiles('/data/fonts')
  for _,file in pairs(files) do
    if g_resources.isFileType(file, 'otfont') and not loaded_files[file] then
      g_fonts.importFont('/data/fonts/' .. file)
    end
  end

  g_mouse.loadCursors('/data/cursors/cursors')
  if layout:len() > 0 and g_resources.directoryExists('/layouts/' .. layout .. '/cursors/cursors') then
    g_mouse.loadCursors('/layouts/' .. layout .. '/cursors/cursors')    
  end
end

function terminate()
end

