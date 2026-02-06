local config = require('brain.config')

local M = {}

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return table.concat(lines, "\n"), start_line, end_line
end

local function create_floating_window(lines, title, start_idx, on_select, on_cancel)
  local width = 70
  local height = math.min(#lines + 2, 20)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  start_idx = start_idx or 1
  
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'brain-select'
  
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set up highlighting namespace
  local ns = vim.api.nvim_create_namespace('brain-select')
  local current_highlight = nil
  
  -- Function to update cursor highlight
  local function update_highlight()
    if current_highlight then
      vim.api.nvim_buf_del_extmark(buf, ns, current_highlight)
    end
    local cursor = vim.api.nvim_win_get_cursor(win)
    local row = cursor[1] - 1
    local line_text = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    current_highlight = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
      end_row = row,
      end_col = #line_text,
      hl_group = 'BrainSelected',
      priority = 100,
    })
  end
  
  -- Set initial cursor position and highlight
  vim.api.nvim_win_set_cursor(win, {start_idx, 0})
  update_highlight()
  
  -- Helper function to get current selection
  local function get_current_index()
    local cursor = vim.api.nvim_win_get_cursor(win)
    return cursor[1]
  end
  
  -- Select item
  local function select_item()
    local idx = get_current_index()
    vim.api.nvim_win_close(win, true)
    if on_select then
      on_select(idx)
    end
  end
  
  -- Cancel
  local function cancel()
    vim.api.nvim_win_close(win, true)
    if on_cancel then
      on_cancel()
    end
  end
  
  -- Keymaps
  vim.keymap.set('n', '<CR>', select_item, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', 'q', cancel, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Esc>', cancel, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', 'j', function()
    local idx = get_current_index()
    if idx < #lines then
      vim.api.nvim_win_set_cursor(win, {idx + 1, 0})
      update_highlight()
    end
  end, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', 'k', function()
    local idx = get_current_index()
    if idx > 1 then
      vim.api.nvim_win_set_cursor(win, {idx - 1, 0})
      update_highlight()
    end
  end, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Down>', function()
    local idx = get_current_index()
    if idx < #lines then
      vim.api.nvim_win_set_cursor(win, {idx + 1, 0})
      update_highlight()
    end
  end, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Up>', function()
    local idx = get_current_index()
    if idx > 1 then
      vim.api.nvim_win_set_cursor(win, {idx - 1, 0})
      update_highlight()
    end
  end, { buffer = buf, silent = true, nowait = true })
end

function M.select_model(callback)
  local models = config.get_all_models()
  
  if #models == 0 then
    vim.notify('Brain: No API keys configured. Please set up at least one provider.', vim.log.levels.ERROR)
    return
  end
  
  local lines = {}
  local current = config.get_current_selection()
  local current_idx = 1
  
  for i, model in ipairs(models) do
    if model.provider == current.provider and model.name == current.model then
      current_idx = i
    end
    table.insert(lines, '  ' .. model.display)
  end
  
  create_floating_window(lines, 'Select AI Model', current_idx, function(idx)
    local selected = models[idx]
    if selected then
      config.set_model(selected.provider, selected.name)
      vim.notify(string.format('Brain: Switched to %s - %s', selected.provider, selected.label), vim.log.levels.INFO)
      if callback then
        callback(selected)
      end
    end
  end)
end

function M.create_prompt_window(callback)
  local width = 70
  local height = 12
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'brain'
  
  local current = config.get_current_selection()
  local current_label = 'Using: ' .. current.provider:gsub("^%l", string.upper) .. ' - ' .. current.model
  
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Brain - What should I do? ',
    title_pos = 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    current_label,
    string.rep('─', width - 2),
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  })
  
  -- Highlight the model info
  local ns = vim.api.nvim_create_namespace('brain-prompt')
  vim.api.nvim_buf_add_highlight(buf, ns, 'Comment', 0, 0, -1)
  
  vim.api.nvim_win_set_cursor(win, {3, 0})
  
  local function close_and_submit()
    local lines = vim.api.nvim_buf_get_lines(buf, 2, -1, false)
    local prompt = table.concat(lines, "\n"):gsub('^%s*(.-)%s*$', '%1')
    vim.api.nvim_win_close(win, true)
    callback(prompt)
  end
  
  local function close_and_change_model()
    vim.api.nvim_win_close(win, true)
    M.select_model(function()
      -- Recursively reopen with new model selected
      M.create_prompt_window(callback)
    end)
  end
  
  vim.keymap.set('n', '<CR>', close_and_submit, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('i', '<CR>', function()
    local row_pos = vim.api.nvim_win_get_cursor(win)[1]
    if row_pos >= 3 then
      close_and_submit()
    else
      return '<CR>'
    end
  end, { buffer = buf, silent = true, expr = true })
  vim.keymap.set('n', '<Tab>', close_and_change_model, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true, nowait = true })
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true, nowait = true })
  
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })
  
  vim.cmd('startinsert')
end

local function make_openai_request(provider, model, prompt, code, callback)
  local full_prompt = string.format(
    "You are a helpful AI coding assistant. Analyze the following code and implement the requested changes:\n\n" ..
    "REQUEST: %s\n\n" ..
    "CODE:\n```\n%s\n```\n\n" ..
    "Provide only the implementation without explanations.",
    prompt, code
  )
  
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output = {}
  local error_output = {}
  
  local handle
  handle = vim.loop.spawn('curl', {
    args = {
      '-s', config.get_base_url(provider) .. '/chat/completions',
      '-H', 'Content-Type: application/json',
      '-H', 'Authorization: Bearer ' .. config.get_api_key(provider),
      '-d', vim.json.encode({
        model = model,
        messages = {
          { role = 'system', content = 'You are a helpful coding assistant. Provide only code, no explanations.' },
          { role = 'user', content = full_prompt }
        }
      })
    },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()
    
    vim.schedule(function()
      if code ~= 0 then
        vim.notify('Brain AI Error: ' .. table.concat(error_output, '\n'), vim.log.levels.ERROR)
        return
      end
      
      local response = table.concat(output, '\n')
      local ok, decoded = pcall(vim.json.decode, response)
      if ok and decoded.choices and decoded.choices[1] then
        callback(decoded.choices[1].message.content)
      else
        vim.notify('Brain: Failed to parse AI response', vim.log.levels.ERROR)
      end
    end)
  end)
  
  vim.loop.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      table.insert(output, data)
    end
  end)
  
  vim.loop.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      table.insert(error_output, data)
    end
  end)
end

local function make_ollama_request(provider, model, prompt, code, callback)
  local full_prompt = string.format(
    "You are a helpful AI coding assistant. Analyze the following code and implement the requested changes:\n\n" ..
    "REQUEST: %s\n\n" ..
    "CODE:\n```\n%s\n```\n\n" ..
    "Provide only the implementation without explanations.",
    prompt, code
  )
  
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output = {}
  local error_output = {}
  
  local handle
  handle = vim.loop.spawn('curl', {
    args = {
      '-s', config.get_base_url(provider) .. '/generate',
      '-H', 'Content-Type: application/json',
      '-d', vim.json.encode({
        model = model,
        system = 'You are a helpful coding assistant. Provide only code, no explanations.',
        prompt = full_prompt,
        stream = false,
      })
    },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()
    
    vim.schedule(function()
      if code ~= 0 then
        vim.notify('Brain AI Error: ' .. table.concat(error_output, '\n'), vim.log.levels.ERROR)
        return
      end
      
      local response = table.concat(output, '\n')
      local ok, decoded = pcall(vim.json.decode, response)
      if ok and decoded.response then
        callback(decoded.response)
      else
        vim.notify('Brain: Failed to parse AI response', vim.log.levels.ERROR)
      end
    end)
  end)
  
  vim.loop.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      table.insert(output, data)
    end
  end)
  
  vim.loop.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      table.insert(error_output, data)
    end
  end)
end

local function make_anthropic_request(provider, model, prompt, code, callback)
  local full_prompt = string.format(
    "You are a helpful AI coding assistant. Analyze the following code and implement the requested changes:\n\n" ..
    "REQUEST: %s\n\n" ..
    "CODE:\n```\n%s\n```\n\n" ..
    "Provide only the implementation without explanations.",
    prompt, code
  )
  
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output = {}
  local error_output = {}
  
  local handle
  handle = vim.loop.spawn('curl', {
    args = {
      '-s', config.get_base_url(provider) .. '/messages',
      '-H', 'Content-Type: application/json',
      '-H', 'x-api-key: ' .. config.get_api_key(provider),
      '-H', 'anthropic-version: 2023-06-01',
      '-d', vim.json.encode({
        model = model,
        max_tokens = 4096,
        system = 'You are a helpful coding assistant. Provide only code, no explanations.',
        messages = {
          { role = 'user', content = full_prompt }
        }
      })
    },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()
    
    vim.schedule(function()
      if code ~= 0 then
        vim.notify('Brain AI Error: ' .. table.concat(error_output, '\n'), vim.log.levels.ERROR)
        return
      end
      
      local response = table.concat(output, '\n')
      local ok, decoded = pcall(vim.json.decode, response)
      if ok and decoded.content and decoded.content[1] then
        callback(decoded.content[1].text)
      else
        vim.notify('Brain: Failed to parse AI response', vim.log.levels.ERROR)
      end
    end)
  end)
  
  vim.loop.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      table.insert(output, data)
    end
  end)
  
  vim.loop.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      table.insert(error_output, data)
    end
  end)
end

local function make_google_request(provider, model, prompt, code, callback)
  local full_prompt = string.format(
    "You are a helpful AI coding assistant. Analyze the following code and implement the requested changes:\n\n" ..
    "REQUEST: %s\n\n" ..
    "CODE:\n```\n%s\n```\n\n" ..
    "Provide only the implementation without explanations.",
    prompt, code
  )
  
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local output = {}
  local error_output = {}
  
  local api_key = config.get_api_key(provider)
  local url = string.format('%s/models/%s:generateContent?key=%s', 
    config.get_base_url(provider), model, api_key)
  
  local handle
  handle = vim.loop.spawn('curl', {
    args = {
      '-s', url,
      '-H', 'Content-Type: application/json',
      '-d', vim.json.encode({
        contents = {
          {
            parts = {
              { text = full_prompt }
            }
          }
        },
        generationConfig = {
          temperature = 0.2,
        }
      })
    },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
    stdout:close()
    stderr:close()
    handle:close()
    
    vim.schedule(function()
      if code ~= 0 then
        vim.notify('Brain AI Error: ' .. table.concat(error_output, '\n'), vim.log.levels.ERROR)
        return
      end
      
      local response = table.concat(output, '\n')
      local ok, decoded = pcall(vim.json.decode, response)
      if ok and decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content then
        local parts = decoded.candidates[1].content.parts
        if parts and parts[1] then
          callback(parts[1].text)
        else
          vim.notify('Brain: Failed to parse AI response', vim.log.levels.ERROR)
        end
      else
        vim.notify('Brain: Failed to parse AI response', vim.log.levels.ERROR)
      end
    end)
  end)
  
  vim.loop.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      table.insert(output, data)
    end
  end)
  
  vim.loop.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      table.insert(error_output, data)
    end
  end)
end

function M.call_ai(prompt, code, callback)
  local selection = config.get_current_selection()
  local provider = selection.provider
  local model = selection.model
  
  if provider == 'openai' or provider == 'groq' or provider == 'deepseek' or provider == 'moonshot' or provider == 'lmstudio' then
    -- OpenAI-compatible APIs
    make_openai_request(provider, model, prompt, code, callback)
  elseif provider == 'anthropic' then
    make_anthropic_request(provider, model, prompt, code, callback)
  elseif provider == 'google' then
    make_google_request(provider, model, prompt, code, callback)
  elseif provider == 'ollama' then
    make_ollama_request(provider, model, prompt, code, callback)
  else
    vim.notify('Brain: Unknown provider ' .. provider, vim.log.levels.ERROR)
  end
end

return M
