local M = {}

local namespace = vim.api.nvim_create_namespace('brain_throbber')
local timer = nil
local active_throbbers = {}

local throbber_frames = {
  "◐",
  "◓", 
  "◑",
  "◒",
}

local current_frame = 1

function M.start_throbber(bufnr, start_line, end_line)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Clear any existing throbber for this buffer
  M.stop_throbber(bufnr)
  
  local throbber_id = {
    bufnr = bufnr,
    start_line = start_line,
    end_line = end_line,
    extmark_ids = {},
  }
  
  -- Create initial extmarks
  local function create_extmarks(frame)
    -- Clear old extmarks
    for _, id in ipairs(throbber_id.extmark_ids) do
      pcall(vim.api.nvim_buf_del_extmark, bufnr, namespace, id)
    end
    throbber_id.extmark_ids = {}
    
    -- Top marker
    local top_virt_text = {{ frame .. " Brain is thinking... " .. frame, 'BrainThrobberActive' }}
    local ok1, id1 = pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, start_line - 2, 0, {
      virt_lines = { top_virt_text },
      virt_lines_above = true,
      hl_mode = 'combine',
    })
    if ok1 then
      table.insert(throbber_id.extmark_ids, id1)
    end
    
    -- Left margin markers for each line
    for i = start_line, end_line do
      local line_frame = throbber_frames[((i + current_frame - 1) % #throbber_frames) + 1]
      local left_text = {{ line_frame .. " ", 'BrainThrobberMargin' }}
      local ok2, id2 = pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, i - 1, 0, {
        virt_text = left_text,
        virt_text_pos = 'inline',
        hl_mode = 'combine',
      })
      if ok2 then
        table.insert(throbber_id.extmark_ids, id2)
      end
    end
    
    -- Bottom marker
    local bottom_virt_text = {{ frame .. " Brain is thinking... " .. frame, 'BrainThrobberActive' }}
    local ok3, id3 = pcall(vim.api.nvim_buf_set_extmark, bufnr, namespace, end_line, 0, {
      virt_lines = { bottom_virt_text },
      virt_lines_above = false,
      hl_mode = 'combine',
    })
    if ok3 then
      table.insert(throbber_id.extmark_ids, id3)
    end
  end
  
  -- Initial render
  create_extmarks(throbber_frames[1])
  
  -- Store throbber info
  active_throbbers[bufnr] = throbber_id
  
  -- Start animation timer
  if not timer then
    timer = vim.loop.new_timer()
  end
  
  timer:start(0, 150, vim.schedule_wrap(function()
    current_frame = (current_frame % #throbber_frames) + 1
    local frame = throbber_frames[current_frame]
    
    for buf, throbber in pairs(active_throbbers) do
      if vim.api.nvim_buf_is_valid(buf) then
        create_extmarks(frame)
      else
        active_throbbers[buf] = nil
      end
    end
    
    -- Redraw to update screen
    vim.cmd('redraw')
  end))
end

function M.stop_throbber(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  if active_throbbers[bufnr] then
    -- Clear extmarks
    for _, id in ipairs(active_throbbers[bufnr].extmark_ids) do
      pcall(vim.api.nvim_buf_del_extmark, bufnr, namespace, id)
    end
    active_throbbers[bufnr] = nil
  end
  
  -- Clear namespace for this buffer
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, namespace, 0, -1)
  
  -- Stop timer if no more active throbbers
  if timer and vim.tbl_isempty(active_throbbers) then
    timer:stop()
  end
end

function M.stop_all_throbbers()
  for bufnr, _ in pairs(active_throbbers) do
    M.stop_throbber(bufnr)
  end
  
  if timer then
    timer:stop()
    timer = nil
  end
end

return M
