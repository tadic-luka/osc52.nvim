local b64 = require('osc52.b64')

local M = {}

function  osc52(data)
  local enc = b64.enc(data)
  return string.format( "%c]52;c;%s%c", 0x1b, enc, 0x07)
end

function  osc52_tmux(data)
  local enc = b64.enc(data)
  return string.format( "%cPtmux;%c%c]52;c;%s%c%c%c", 0x1b, 0x1b, 0x1b, enc, 0x07, 0x1b, 0x5c)
end


function M.yank_str(str)
  local length = string.len(str)
  local limit = 100000

  local data = ""
  
  if length > limit  then
    vim.api.nvim_notify('[osc52] Selection has length ' .. length .. ', limit is ' .. limit, vim.log.levels.ERROR, {})
    return
  end

  if vim.env.TMUX then
    data = osc52_tmux(str)
  else
    data = osc52(str)
  end
  vim.api.nvim_chan_send(vim.v.stderr, data)
end

local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  else
    return cerow - 1, cecol - 1, csrow - 1, cscol
  end
end

vim.api.nvim_create_user_command(
  'OSCYank',
  function(opts)
    M.yank_str(opts.args)
  end,
  { nargs = 1}
)

vim.api.nvim_create_user_command(
  'OSCYankReg',
  function(opts)
    M.yank_str(vim.fn.getreg(opts.args))
  end,
  { nargs = 1}
)

vim.api.nvim_create_user_command(
  'OSCYankRange',
  function(opts)
    local _, _, col_start, _ = unpack(vim.fn.getpos("'<"))
    local _, _, col_end, _ = unpack(vim.fn.getpos("'>"))
    local lines = vim.fn.getline(opts.line1, opts.line2)

    for i, line in ipairs(lines) do
      lines[i] = string.sub(lines[i], col_start, col_end)
    end

    M.yank_str(table.concat(lines, "\n"))
  end,
  { range = '%'}
)



return M
