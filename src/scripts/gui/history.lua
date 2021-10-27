local gui = require("__flib__.gui")
local misc = require("__flib__.misc")

local constants = require("constants")
local util = require("scripts.util")

local templates = require("templates")

local history_tab = {}

function history_tab.build(widths)
  return {
    tab = {
      type = "tab",
      caption = {"gui.ltnm-history"},
      ref = {"history", "tab"},
      actions = {
        on_click = {gui = "main", action = "change_tab", tab = "history"},
      },
    },
    content = {
      type = "frame",
      style = "ltnm_main_content_frame",
      direction = "vertical",
      ref = {"history", "content_frame"},
      {type = "frame", style = "ltnm_table_toolbar_frame",
        templates.sort_checkbox(
          widths,
          "history",
          "train_id",
          false
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "route",
          false
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "depot",
          false
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "network_id",
          false
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "runtime",
          false
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "finished",
          true,
          nil,
          true
        ),
        templates.sort_checkbox(
          widths,
          "history",
          "shipment",
          false
        ),
      },
      {type = "scroll-pane", style = "ltnm_table_scroll_pane", ref = {"history", "scroll_pane"}},
      {type = "flow", style = "ltnm_warning_flow", visible = false, ref = {"history", "warning_flow"},
        {
          type = "label",
          style = "ltnm_semibold_label",
          caption = {"gui.ltnm-no-history"},
          ref = {"history", "warning_label"},
        },
      },
    },
  }
end

function history_tab.update(self)
  local dictionaries = self.player_table.dictionaries

  local state = self.state
  local refs = self.refs.history
  local widths = self.widths

  local search_query = state.search_query
  local search_network_id = state.network_id
  local search_surface = state.surface

  local ltn_history = state.ltn_data.history
  local scroll_pane = refs.scroll_pane
  local children = scroll_pane.children

  local sorts = state.sorts[state.active_tab]
  local active_sort = sorts._active
  local sorted_history = state.ltn_data.sorted_history[active_sort]

  local table_index = 0

  -- False = ascending (arrow down), True = descending (arrow up)
  local start, finish, step
  if sorts[active_sort] then
    start = #sorted_history
    finish = 1
    step = -1
  else
    start = 1
    finish = #sorted_history
    step = 1
  end

  for sorted_index = start, finish, step do
    local train_id = sorted_history[sorted_index]
    local history_entry = ltn_history[train_id]

    if
      (search_surface == -1 or (history_entry.surface_index == search_surface))
      and bit32.btest(history_entry.network_id, search_network_id)
      and (
        #search_query == 0 or string.find(history_entry.search_strings[self.player.index], string.lower(search_query))
      )
    then
      table_index = table_index + 1
      local row = children[table_index]
      local color = table_index % 2 == 0 and "dark" or "light"
      if not row then
        row = gui.add(scroll_pane,
          {type = "frame", style = "ltnm_table_row_frame_"..color,
            {
              type = "label",
              style = "ltnm_clickable_semibold_label",
              style_mods = {width = widths.history.train_id, horizontal_align = "center"}
            },
            {
              type = "label",
              style = "ltnm_clickable_semibold_label",
              style_mods = {width = widths.history.route}
            },
            {type = "label", style_mods = {width = widths.history.depot}},
            {type = "label", style_mods = {width = widths.history.network_id, horizontal_align = "center"}},
            {type = "label", style_mods = {width = widths.history.finished, horizontal_align = "center"}},
            {type = "label", style_mods = {width = widths.history.runtime, horizontal_align = "center"}},
            {
              type = "frame",
              name = "shipment_frame",
              style = "ltnm_small_slot_table_frame_"..color,
              style_mods = {width = widths.history.shipment},
              {type = "table", name = "shipment_table", style = "slot_table", column_count = 4},
            },
            -- {type = "empty-widget", style = "flib_horizontal_pusher"},
          }
        )
      end

      -- local station_id = status.station and history_entry[status.station.."_id"] or nil

      gui.update(row,
        {
          {
            elem_mods = {caption = history_entry.train_id},
            actions = {
              on_click = {gui = "main", action = "open_train_gui", train_id = history_entry.train_id},
            },
          },
          {
            elem_mods = {caption = history_entry.route},
            -- actions = {
            --   on_click = station_id
            --     and {gui = "main", action = "open_station_gui", station_id = station_id}
            --     or false,
            -- },
          },
          {elem_mods = {caption = history_entry.depot}},
          {elem_mods = {caption = history_entry.network_id}},
          {elem_mods = {caption = misc.ticks_to_timestring(history_entry.runtime)}},
          {elem_mods = {caption = misc.ticks_to_timestring(history_entry.finished)}},
        }
      )

      util.slot_table_update(
        row.shipment_frame.shipment_table,
        {{color = "default", entries = history_entry.shipment, translations = dictionaries.materials}}
      )
    end
  end

  for child_index = table_index + 1, #children do
    children[child_index].destroy()
  end

  if table_index == 0 then
    refs.warning_flow.visible = true
    scroll_pane.visible = false
    refs.content_frame.style = "ltnm_main_warning_frame"
  else
    refs.warning_flow.visible = false
    scroll_pane.visible = true
    refs.content_frame.style = "ltnm_main_content_frame"
  end

end

return history_tab