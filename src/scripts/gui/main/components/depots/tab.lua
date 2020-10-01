local component = require("lib.gui-component")()

local depot_select = require("scripts.gui.main.components.depots.depot-select")
local trains_list = require("scripts.gui.main.components.depots.trains-list")

function component.update(player, player_table, state, refs, msg)
  if msg.update then
    depot_select.update(player, player_table, state, refs, msg)
    -- TODO
    -- trains_list.update(player, player_table, state, refs, msg)
  end
end

function component.build()
  return (
    {
      type = "tab-and-content",
      tab = {type = "tab", caption = {"ltnm-gui.depots"}},
      content = (
        {type = "flow", style = "ltnm_tab_horizontal_flow", children = {
          depot_select(),
          trains_list()
        }}
      )
    }
  )
end

return component