local M = {}

-- Default configuration
M.config = {
  default_provider = 'openai',
  default_model = nil, -- Will use provider's default
  providers = {
    openai = {
      api_key = nil, -- Set via vim.g.brain_openai_key or $OPENAI_API_KEY
      base_url = 'https://api.openai.com/v1',
      models = {
        { name = 'gpt-4o', label = 'GPT-4o', description = 'Most capable multimodal model' },
        { name = 'gpt-4o-mini', label = 'GPT-4o Mini', description = 'Fast and affordable' },
        { name = 'gpt-4-turbo', label = 'GPT-4 Turbo', description = 'High performance' },
        { name = 'gpt-3.5-turbo', label = 'GPT-3.5 Turbo', description = 'Fast and cost-effective' },
      },
      default_model = 'gpt-4o-mini',
    },
    anthropic = {
      api_key = nil, -- Set via vim.g.brain_anthropic_key or $ANTHROPIC_API_KEY
      base_url = 'https://api.anthropic.com/v1',
      models = {
        { name = 'claude-3-5-sonnet-20241022', label = 'Claude 3.5 Sonnet', description = 'Most intelligent model' },
        { name = 'claude-3-opus-20240229', label = 'Claude 3 Opus', description = 'Powerful for complex tasks' },
        { name = 'claude-3-sonnet-20240229', label = 'Claude 3 Sonnet', description = 'Balanced performance' },
        { name = 'claude-3-haiku-20240307', label = 'Claude 3 Haiku', description = 'Fastest responses' },
      },
      default_model = 'claude-3-5-sonnet-20241022',
    },
    google = {
      api_key = nil, -- Set via vim.g.brain_google_key or $GOOGLE_API_KEY
      base_url = 'https://generativelanguage.googleapis.com/v1beta',
      models = {
        { name = 'gemini-1.5-pro', label = 'Gemini 1.5 Pro', description = 'Most capable' },
        { name = 'gemini-1.5-flash', label = 'Gemini 1.5 Flash', description = 'Fast and efficient' },
      },
      default_model = 'gemini-1.5-pro',
    },
    groq = {
      api_key = nil, -- Set via vim.g.brain_groq_key or $GROQ_API_KEY
      base_url = 'https://api.groq.com/openai/v1',
      models = {
        { name = 'llama-3.1-70b-versatile', label = 'Llama 3.1 70B', description = 'Meta Llama 3.1 70B' },
        { name = 'llama-3.1-8b-instant', label = 'Llama 3.1 8B', description = 'Fast Meta Llama 3.1 8B' },
        { name = 'mixtral-8x7b-32768', label = 'Mixtral 8x7B', description = 'Mistral Mixtral' },
        { name = 'gemma2-9b-it', label = 'Gemma 2 9B', description = 'Google Gemma 2' },
      },
      default_model = 'llama-3.1-70b-versatile',
    },
    ollama = {
      api_key = 'ollama', -- Not actually used, but required for consistency
      base_url = 'http://localhost:11434/api',
      models = {
        { name = 'codellama', label = 'CodeLlama', description = 'Meta CodeLlama (free, local)' },
        { name = 'llama3.1', label = 'Llama 3.1', description = 'Meta Llama 3.1 (free, local)' },
        { name = 'mistral', label = 'Mistral', description = 'Mistral 7B (free, local)' },
        { name = 'deepseek-coder', label = 'DeepSeek Coder', description = 'DeepSeek Coder (free, local)' },
        { name = 'phi4', label = 'Phi-4', description = 'Microsoft Phi-4 (free, local)' },
        { name = 'qwen2.5', label = 'Qwen 2.5', description = 'Alibaba Qwen 2.5 (free, local)' },
      },
      default_model = 'codellama',
      is_local = true,
    },
    lmstudio = {
      api_key = 'lmstudio', -- Not actually used, but required for consistency
      base_url = 'http://localhost:1234/v1',
      models = {
        { name = 'local-model', label = 'Local Model', description = 'Any model loaded in LM Studio (free, local)' },
      },
      default_model = 'local-model',
      is_local = true,
    },
    deepseek = {
      api_key = nil, -- Set via vim.g.brain_deepseek_key or $DEEPSEEK_API_KEY
      base_url = 'https://api.deepseek.com/v1',
      models = {
        { name = 'deepseek-chat', label = 'DeepSeek Chat', description = 'DeepSeek-V3 (very affordable)' },
        { name = 'deepseek-coder', label = 'DeepSeek Coder', description = 'DeepSeek Coder V2 (very affordable)' },
      },
      default_model = 'deepseek-coder',
    },
    moonshot = {
      api_key = nil, -- Set via vim.g.brain_moonshot_key or $MOONSHOT_API_KEY
      base_url = 'https://api.moonshot.cn/v1',
      models = {
        { name = 'moonshot-v1-8k', label = 'Kimi K2 8K', description = 'Kimi K2 8K context (affordable)' },
        { name = 'moonshot-v1-32k', label = 'Kimi K2 32K', description = 'Kimi K2 32K context (affordable)' },
        { name = 'moonshot-v1-128k', label = 'Kimi K2 128K', description = 'Kimi K2 128K context (affordable)' },
      },
      default_model = 'moonshot-v1-32k',
    },
    opencode_zen = {
      api_key = nil, -- Set via vim.g.brain_opencode_zen_key or $OPENCODE_ZEN_API_KEY
      base_url = 'https://opencode.ai/api/v1',
      models = {
        { name = 'qwen3-coder-480b', label = 'Qwen 3 Coder 480B', description = 'Hand-picked coding model' },
        { name = 'deepseek', label = 'DeepSeek', description = 'DeepSeek model' },
        { name = 'claude-3-5-sonnet', label = 'Claude 3.5 Sonnet', description = 'Anthropic Claude 3.5 Sonnet' },
        { name = 'gpt-4o', label = 'GPT-4o', description = 'OpenAI GPT-4o' },
      },
      default_model = 'qwen3-coder-480b',
    },
    github_copilot = {
      api_key = nil, -- Uses GitHub Copilot authentication
      base_url = 'https://api.github.com/copilot',
      models = {
        { name = 'claude-3.5-sonnet', label = 'Claude 3.5 Sonnet', description = 'Anthropic Claude 3.5 Sonnet via Copilot' },
        { name = 'gpt-4o', label = 'GPT-4o', description = 'OpenAI GPT-4o via Copilot' },
        { name = 'gemini-1.5-pro', label = 'Gemini 1.5 Pro', description = 'Google Gemini 1.5 Pro via Copilot' },
      },
      default_model = 'claude-3.5-sonnet',
    },
  },
}

-- Current selection (persisted during session)
M.current_provider = nil
M.current_model = nil

function M.setup(opts)
  opts = opts or {}
  
  -- Merge user config with defaults
  if opts.providers then
    for provider, config in pairs(opts.providers) do
      if M.config.providers[provider] then
        M.config.providers[provider] = vim.tbl_deep_extend('force', M.config.providers[provider], config)
      end
    end
  end
  
  if opts.default_provider then
    M.config.default_provider = opts.default_provider
  end
  
  if opts.default_model then
    M.config.default_model = opts.default_model
  end
  
  -- Load API keys from environment variables if not set
  M.load_api_keys()
  
  -- Set initial provider and model
  M.current_provider = M.config.default_provider
  M.current_model = M.config.default_model or M.config.providers[M.current_provider].default_model
end

function M.load_api_keys()
  -- Try to load API keys from environment variables
  local env_vars = {
    openai = 'OPENAI_API_KEY',
    anthropic = 'ANTHROPIC_API_KEY',
    google = 'GOOGLE_API_KEY',
    groq = 'GROQ_API_KEY',
    deepseek = 'DEEPSEEK_API_KEY',
    moonshot = 'MOONSHOT_API_KEY',
    opencode_zen = 'OPENCODE_ZEN_API_KEY',
  }
  
  for provider, env_var in pairs(env_vars) do
    if M.config.providers[provider] and not M.config.providers[provider].api_key then
      M.config.providers[provider].api_key = vim.g['brain_' .. provider .. '_key'] or os.getenv(env_var)
    end
  end
  
  -- Local providers don't need real API keys, just mark them as available
  if not M.config.providers.ollama.api_key then
    M.config.providers.ollama.api_key = 'ollama-local'
  end
  if not M.config.providers.lmstudio.api_key then
    M.config.providers.lmstudio.api_key = 'lmstudio-local'
  end
  
  -- Check for GitHub Copilot authentication
  -- Try to get token from copilot.lua plugin or check for token file
  if not M.config.providers.github_copilot.api_key then
    local copilot_token = nil
    
    -- Try to get token from copilot.lua plugin's internal state
    local ok, copilot = pcall(require, 'copilot')
    if ok then
      -- copilot.lua is installed, check if authenticated
      copilot_token = 'copilot-authenticated'
    end
    
    -- Alternative: check for GitHub CLI token
    if not copilot_token then
      local gh_token = vim.fn.system('gh auth token 2>/dev/null'):gsub('%s+', '')
      if gh_token and #gh_token > 0 and vim.v.shell_error == 0 then
        copilot_token = 'gh-cli-auth'
      end
    end
    
    -- Check for Copilot token file
    if not copilot_token then
      local token_path = vim.fn.expand('~/.config/github-copilot/hosts.json')
      if vim.fn.filereadable(token_path) == 1 then
        copilot_token = 'copilot-token-file'
      end
    end
    
    if copilot_token then
      M.config.providers.github_copilot.api_key = copilot_token
    end
  end
end

function M.get_api_key(provider)
  return M.config.providers[provider].api_key
end

function M.get_base_url(provider)
  return M.config.providers[provider].base_url
end

function M.get_all_models()
  local all_models = {}
  
  for provider, config in pairs(M.config.providers) do
    if M.get_api_key(provider) then
      for _, model in ipairs(config.models) do
        table.insert(all_models, {
          provider = provider,
          name = model.name,
          label = model.label,
          description = model.description,
          display = string.format('%s - %s (%s)', provider:gsub("^%l", string.upper), model.label, model.description),
        })
      end
    end
  end
  
  table.sort(all_models, function(a, b)
    return a.display < b.display
  end)
  
  return all_models
end

function M.set_model(provider, model)
  if not M.config.providers[provider] then
    vim.notify('Brain: Unknown provider ' .. provider, vim.log.levels.ERROR)
    return false
  end
  
  -- Validate model exists for provider
  local model_exists = false
  for _, m in ipairs(M.config.providers[provider].models) do
    if m.name == model then
      model_exists = true
      break
    end
  end
  
  if not model_exists then
    vim.notify('Brain: Model ' .. model .. ' not found for provider ' .. provider, vim.log.levels.ERROR)
    return false
  end
  
  M.current_provider = provider
  M.current_model = model
  
  return true
end

function M.get_current_selection()
  return {
    provider = M.current_provider,
    model = M.current_model,
  }
end

return M
