function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function TupletDelayCalc(lines, notecount)
    local ticks_pernote = (lines * 256) / notecount
    local count = lines * 256
    local counter = 0
    local loc = {}
    
    repeat
      table.insert(loc, {line = math.floor(counter / 256) + 1, delay = round(counter % 256)})
      counter = counter + ticks_pernote
    until counter >= count
    
    return loc
end

function clearDelay(lines)
  local trackindx = renoise.song().selected_track_index
  local patternindx = renoise.song().selected_pattern_index
  local linei = renoise.song().selected_line_index
  for i = linei,linei + lines do
    if i > renoise.song().patterns[patternindx].number_of_lines then break end
    renoise.song().patterns[patternindx].tracks[trackindx].lines[i].note_columns[1].delay_value = 0
  end
end

function addDelay(lines, notecount)
  clearDelay(lines)
  local posTable = TupletDelayCalc(lines, notecount)
  local lineoffset = renoise.song().selected_line_index
  local trackindx = renoise.song().selected_track_index
  local patternindx = renoise.song().selected_pattern_index
  renoise.song().tracks[trackindx].delay_column_visible = true
  
  for k,v in pairs(posTable) do
  print("hi")
    if (v.line+lineoffset-1) > renoise.song().patterns[patternindx].number_of_lines then break end
    renoise.song().patterns[patternindx].tracks[trackindx].lines[v.line+lineoffset-1].note_columns[1].delay_value = v.delay
  end
end

--

function gui()
  local vb = renoise.ViewBuilder()
  local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  
  local textfield_row = vb:row {
    margin = DIALOG_MARGIN,
    spacing = CONTENT_SPACING,
    vb:text {
      width = 80,
      text = "Amount of Lines "
    },
    vb:textfield {
      id = "lines_txt",
      width = 120,
      text = "",
      notifier = nil
    }
  }
  local textfield_row2 = vb:row {
    margin = DIALOG_MARGIN,
    spacing = CONTENT_SPACING,
    vb:text {
      width = 80,
      text = "Number of notes "
    },
    vb:textfield {
      id = "notes_txt",
      width = 120,
      text = "",
      notifier = nil
    }
  }
  local ok_btn = vb:column {
    id = "ok_btn",
    margin = DIALOG_MARGIN,
    spacing = CONTENT_SPACING,
    
    vb:button {
    text = "Add notes",
      tooltip = "Magic!!",
      notifier = function()
        local l = vb.views.lines_txt.text
        local n = vb.views.notes_txt.text
        addDelay(l, n)
      end
    }
  }
  
  local final_layout = vb:column {
    textfield_row, textfield_row2, ok_btn
  }
  
  renoise.app():show_custom_dialog("Tuplet Adder", final_layout)
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Edit:Add Tuplet...",
  invoke = function() gui() end 
}


