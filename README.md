# Brain

An AI-powered code assistant for Neovim that lets you select code and ask an AI to implement or modify it. Supports multiple AI providers including **FREE local options**!

## Features

- Select code in visual mode and trigger Brain with `:Brain` or a keybinding
- Floating window interface for entering your request
- **Choose from multiple AI providers**: OpenAI, Anthropic, Google Gemini, Groq, **DeepSeek**, **Moonshot (Kimi)**, **OpenCode Zen**, **GitHub Copilot**, **Ollama** (free/local), **LM Studio** (free/local)
- **Model picker UI**: Select which model to use with `<Tab>` in the prompt window
- **Visual throbber**: Animated indicators show which code Brain is working on
- Asynchronous AI processing - continue editing while Brain works
- Automatically replaces your selected code with the AI's implementation

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/brain',
  config = function()
    require('brain').setup({
      default_provider = 'openai', -- or 'anthropic', 'google', 'groq'
      default_model = nil, -- nil uses provider's default
      providers = {
        openai = {
          api_key = 'your-openai-api-key', -- or $OPENAI_API_KEY
        },
        anthropic = {
          api_key = 'your-anthropic-key', -- or $ANTHROPIC_API_KEY
        },
        -- Add other providers as needed
      },
    })
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/brain',
  config = function()
    require('brain').setup({
      default_provider = 'ollama',  -- FREE local option!
      providers = {
        -- Cloud providers (require API keys)
        openai = { api_key = vim.env.OPENAI_API_KEY },
        anthropic = { api_key = vim.env.ANTHROPIC_API_KEY },
        google = { api_key = vim.env.GOOGLE_API_KEY },
        groq = { api_key = vim.env.GROQ_API_KEY },
        deepseek = { api_key = vim.env.DEEPSEEK_API_KEY },  -- Very affordable
        moonshot = { api_key = vim.env.MOONSHOT_API_KEY },  -- Kimi models
        opencode_zen = { api_key = vim.env.OPENCODE_ZEN_API_KEY },  -- Curated models
        github_copilot = {},  -- GitHub Copilot (uses existing auth)
        
        -- Local providers (FREE - no API keys needed!)
        ollama = {},  -- Make sure Ollama is running: http://localhost:11434
        lmstudio = {},  -- Make sure LM Studio server is running: http://localhost:1234
      },
    })
  end
}
```

## Supported Providers

### OpenAI
- **Models**: GPT-4o, GPT-4o Mini, GPT-4 Turbo, GPT-3.5 Turbo
- **API Key**: `OPENAI_API_KEY` environment variable or `vim.g.brain_openai_key`

### Anthropic
- **Models**: Claude 3.5 Sonnet, Claude 3 Opus, Claude 3 Sonnet, Claude 3 Haiku
- **API Key**: `ANTHROPIC_API_KEY` environment variable or `vim.g.brain_anthropic_key`

### Google
- **Models**: Gemini 1.5 Pro, Gemini 1.5 Flash
- **API Key**: `GOOGLE_API_KEY` environment variable or `vim.g.brain_google_key`

### Groq
- **Models**: Llama 3.1 70B, Llama 3.1 8B, Mixtral 8x7B, Gemma 2 9B
- **API Key**: `GROQ_API_KEY` environment variable or `vim.g.brain_groq_key`

### DeepSeek ⭐ Affordable
- **Models**: DeepSeek Chat, DeepSeek Coder V2
- **Pricing**: Very affordable pay-as-you-go
- **API Key**: `DEEPSEEK_API_KEY` environment variable or `vim.g.brain_deepseek_key`

### Moonshot AI (Kimi) ⭐ Affordable
- **Models**: Kimi K2 8K/32K/128K context
- **Pricing**: Competitive rates
- **API Key**: `MOONSHOT_API_KEY` environment variable or `vim.g.brain_moonshot_key`

### OpenCode Zen ⭐ Curated
- **Models**: Qwen 3 Coder 480B, DeepSeek, Claude 3.5 Sonnet, GPT-4o, and more
- **Description**: Hand-picked models tested and verified specifically for coding agents
- **API Key**: `OPENCODE_ZEN_API_KEY` environment variable or `vim.g.brain_opencode_zen_key`
- **Setup**: Get your API key at [opencode.ai/auth](https://opencode.ai/auth)

### GitHub Copilot
- **Models**: Claude 3.5 Sonnet, GPT-4o, Gemini 1.5 Pro (depending on subscription)
- **Requirements**: Active GitHub Copilot subscription (Individual, Business, or Enterprise)
- **Setup**: Authenticate via OAuth or use existing GitHub Copilot token
- **Note**: Some models require Copilot Pro+ subscription

### Ollama 🆓 **FREE & LOCAL**
- **Models**: CodeLlama, Llama 3.1, Mistral, DeepSeek Coder, Phi-4, Qwen 2.5
- **Cost**: **Completely FREE!** Runs locally on your machine
- **Setup**: Install [Ollama](https://ollama.com) and run models locally
- **No API key required!** Just make sure Ollama is running on `localhost:11434`

### LM Studio 🆓 **FREE & LOCAL**
- **Models**: Any model you load in LM Studio
- **Cost**: **Completely FREE!** Runs locally on your machine
- **Setup**: Install [LM Studio](https://lmstudio.ai) and start the local server
- **No API key required!** Just make sure LM Studio server is running on `localhost:1234`

## Configuration

### Environment Variables

You can set API keys via environment variables:
```bash
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
export GOOGLE_API_KEY="your-key"
export GROQ_API_KEY="your-key"
export DEEPSEEK_API_KEY="your-key"        # DeepSeek - very affordable
export MOONSHOT_API_KEY="your-key"        # Moonshot AI (Kimi)
export OPENCODE_ZEN_API_KEY="your-key"    # OpenCode Zen - curated models
```

For GitHub Copilot, authentication is handled via OAuth or your existing GitHub Copilot subscription.

Or in your Neovim config:
```lua
vim.g.brain_openai_key = 'your-key'
vim.g.brain_anthropic_key = 'your-key'
-- etc.
```

### Setup Options

```lua
require('brain').setup({
  default_provider = 'openai', -- default: 'openai'
  default_model = 'gpt-4o', -- nil uses provider's default
  providers = {
    openai = {
      api_key = 'your-key',
      -- Optional: customize available models
      models = {
        { name = 'gpt-4o', label = 'GPT-4o', description = 'Most capable' },
        { name = 'gpt-4o-mini', label = 'GPT-4o Mini', description = 'Fast' },
      }
    },
  },
})
```

## Usage

### Basic Workflow

1. Select code in visual mode (visual line mode works best)
2. Run `:Brain` or press `<leader>ai`
3. Type your request in the floating window
4. Press `Enter` to submit, or `q`/`Esc` to cancel
5. The AI will process your request asynchronously and replace the selected code

### Changing Models

**Option 1**: During a Brain session
- Press `<Tab>` in the prompt window to open the model picker
- Navigate with `j`/`k` and press `Enter` to select
- The prompt window reopens with the new model selected

**Option 2**: Direct model selection
- Run `:BrainModel` or press `<leader>am` to open the model picker
- Navigate and select your desired model
- The model will be used for the next Brain session

### Example Workflow

1. Select a function definition with `V`
2. Run `:Brain`
3. Type "Add error handling to this function"
4. **Press `<Tab>`** if you want to switch models (e.g., to Claude 3.5 Sonnet)
5. Select the model and press Enter
6. Press Enter again to submit your request
7. Continue editing while Brain works
8. The function is automatically updated with error handling

## Commands

- `:Brain` - Trigger Brain with selected code (visual mode)
- `:BrainModel` - Open the model picker to change AI model

## Keybindings

Default keybindings (can be customized):

- `<leader>ai` - Trigger Brain in visual mode
- `<leader>am` - Open model picker

Customize in your config:
```lua
vim.keymap.set('v', '<your-key>', function()
  require('brain').think()
end, { desc = 'Brain: Ask AI to modify selected code' })

vim.keymap.set('n', '<your-key>', function()
  require('brain').select_model()
end, { desc = 'Brain: Select AI model' })
```

## Model Selection UI

The model picker shows:
- **Current model** marked with `►`
- All available models from configured providers
- Provider name, model label, and description
- Models sorted alphabetically

Navigate with:
- `j`/`k` - Move up/down
- `Enter` - Select model
- `q`/`Esc` - Cancel

## Visual Throbber

When Brain is processing your request, animated visual indicators appear around the selected code:

```
◐ Brain is thinking... ◐
◒  function myCode() {
◓    // Your selected
◑    // code block
◒  }
◐ Brain is thinking... ◐
```

The throbber shows:
- **Top and bottom borders** with animated spinning indicators
- **Left margin indicators** on each line of the selected code
- **Animated frames** (◐ ◓ ◑ ◒) that cycle while processing
- Automatically disappears when the AI response is ready

The throbber uses highlight groups you can customize:
- `BrainThrobberActive` - Color for top/bottom borders (default: blue, bold)
- `BrainThrobberMargin` - Color for left margin indicators (default: green, bold)

Customize colors in your config:
```lua
vim.api.nvim_set_hl(0, 'BrainThrobberActive', { fg = '#ff6b6b', bold = true })
vim.api.nvim_set_hl(0, 'BrainThrobberMargin', { fg = '#4ecdc4', bold = true })
```

## 💰 Cost-Effective Options

### Completely FREE (Local)
1. **Ollama** - Download and run models locally. No API costs ever!
2. **LM Studio** - GUI for running local models. Great for beginners.

Both work offline and keep your code private.

### Very Affordable (Cloud)
1. **DeepSeek** - DeepSeek Coder V2 is extremely capable and costs a fraction of OpenAI
2. **Moonshot AI (Kimi)** - Kimi K2 models are competitively priced with excellent performance
3. **Groq** - Fast inference, often has free credits for new users
4. **OpenCode Zen** - Curated models at competitive rates, tested specifically for coding

### Subscription-Based
1. **GitHub Copilot** - If you already have a GitHub Copilot subscription, use it with Brain!

### Premium (Cloud)
1. **OpenAI** - GPT-4o is state-of-the-art but more expensive
2. **Anthropic** - Claude 3.5 Sonnet is excellent for complex coding tasks
3. **Google** - Gemini 1.5 Pro with huge context windows

## Requirements

- Neovim 0.7+
- `curl` command available
- At least one AI provider configured (API key for cloud, local server running for free options)

## License

MIT
