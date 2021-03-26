-- make the window occupy the entire screen
hs.hotkey.bind({"alt", "cmd"}, "f", function()
      local win = hs.window.focusedWindow()
      local f = win:frame()
      local screen = win:screen()
      local max = screen:frame()
      win:setFrame({
            x = max.x,
            y = max.y,
            w = max.w,
            h = max.h,
      })
end)

-- resize

local function atedges(scr, win)
   local fuzz = 10
   return {
      left  = math.abs(win.x - scr.x) <= fuzz,
      right = math.abs((win.x + win.w) - (scr.x + scr.w)) <= fuzz,
      up    = math.abs(win.y - scr.y) <= fuzz,
      down  = math.abs((win.y + win.h) - (scr.y + scr.h)) <= fuzz,
   }
end

local resize_steps_up = { 0.33, 0.5, 0.66, 1 }
local resize_steps_down = { 0.66, 0.5, 0.33 }
local resize = {
   -- adapt width/height by growing the window in given direction,
   -- until it hits the edge of the screen; afterwards shrink it from
   -- the other side.

   right = function(scr, win)
      local edges = atedges(scr, win)
      if not edges.right then
         for _, step in ipairs(resize_steps_up) do
            if (scr.w * step * 0.9) > win.w then
               win.w = scr.w * step
               break
            end
         end
         if win.w + win.x > scr.w + scr.x then
            win.x = scr.x + (scr.w - win.w)
         end
      else
         for _, step in ipairs(resize_steps_down) do
            if (scr.w * step * 1.1) < win.w then
               win.w = scr.w * step
               win.x = scr.x + (scr.w - win.w)
               break
            end
         end
      end
      return win
   end,

   left = function(scr, win)
      local edges = atedges(scr, win)
      if not edges.left then
         for _, step in ipairs(resize_steps_up) do
            if (scr.w * step * 0.9) > win.w then
               win.w = scr.w * step
               win.x = scr.x + (scr.w - win.w)
               break
            end
         end
      else
         for _, step in ipairs(resize_steps_down) do
            if (scr.w * step * 1.1) < win.w then
               win.w = scr.w * step
               break
            end
         end
      end
      return win
   end,

   down = function(scr, win)
      local edges = atedges(scr, win)
      if not edges.down then
         for _, step in ipairs(resize_steps_up) do
            if (scr.h * step * 0.9) > win.h then
               win.h = scr.h * step
               break
            end
         end
         if win.h + win.y > scr.h + scr.y then
            win.y = scr.y + (scr.h - win.h)
         end
      else
         for _, step in ipairs(resize_steps_down) do
            if (scr.h * step * 1.1) < win.h then
               win.h = scr.h * step
               win.y = scr.y + (scr.h - win.h)
               break
            end
         end
      end
      return win
   end,

   up = function(scr, win)
      local edges = atedges(scr, win)
      if not edges.up then
         for _, step in ipairs(resize_steps_up) do
            if (scr.h * step * 0.9) > win.h then
               win.h = scr.h * step
               win.y = scr.y + (scr.h - win.h)
               break
            end
         end
      else
         for _, step in ipairs(resize_steps_down) do
            if (scr.h * step * 1.1) < win.h then
               win.h = scr.h * step
               break
            end
         end
      end
      return win
   end,

}

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function()
      local win = hs.window.focusedWindow()
      win:setFrame(resize.right(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function()
      local win = hs.window.focusedWindow()
      win:setFrame(resize.left(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Down", function()
      local win = hs.window.focusedWindow()
      win:setFrame(resize.down(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Up", function()
      local win = hs.window.focusedWindow()
      win:setFrame(resize.up(win:screen():frame(), win:frame()))
end)

-- move the window in a direction, pushing it towards the center, or the edge of the screen.
--
--
-- 0 x                               w
-- ___________________________________ 0
-- |m_e_n_u_b_a_r____________________| y
-- |                                 |
-- |_                                |
-- |d|                               |
-- |o|                               |
-- |c|                               |
-- |k|                               |
-- |_|                               |
-- |                                 |
-- |                                 |
-- |_________________________________| h
--
--
-- x                               w
-- ___________________________________ 0
-- |m_e_n_u_b_a_r____________________| y
-- |                                 |
-- |                                _|
-- |                               |d|
-- |                               |o|
-- |                               |c|
-- |                               |k|
-- |                               |_|
-- |                                 |
-- |                                 |
-- |_________________________________| h
--
-- x                                 w
-- ___________________________________ 0
-- |m_e_n_u_b_a_r____________________| y
-- |                                 |
-- |                                 |
-- |                                 |
-- |                                 |
-- |                                 |
-- |                                 |
-- |                                 |
-- |                                 |
-- |         ___________             | h
-- |_________|_d_o_c_k_|_____________|
--


local overlap = 20
local move = {
   left = function (scr, win)
      local sxc = scr.x + ((scr.w - scr.x) / 2)
      local wxc = win.x + win.w / 2
      if wxc <= (sxc + overlap) then
         -- we're in the left half, push to the edge
         return {
            x = scr.x,
            y = win.y,
            w = win.w,
            h = win.h,
         }
      else
         -- we're in the right half, push to the center
         return {
            x = sxc - (win.w / 2),
            y = win.y,
            w = win.w,
            h = win.h,
         }
      end
   end,
   right = function (scr, win)
      local sxc = scr.x + ((scr.w - scr.x) / 2)
      local wxc = win.x + win.w / 2
      if wxc < (sxc - overlap) then
         -- we're in the left half, push to the center
         return {
            x = sxc - (win.w / 2),
            y = win.y,
            w = win.w,
            h = win.h,
         }
      else
         -- we're in the right half, push to the edge
         return {
            x = scr.x + (scr.w - win.w),
            y = win.y,
            w = win.w,
            h = win.h,
         }
      end
   end,
   up = function (scr, win)
      local syc = scr.y + ((scr.h - scr.y) / 2)
      local wyc = win.y + win.h / 2
      if wyc <= (syc + overlap) then
         -- we're in the top half, push to the edge
         return {
            x = win.x,
            y = scr.y,
            w = win.w,
            h = win.h,
         }
      else
         -- we're in the bottom half, push to the center
         return {
            x = win.x,
            y = syc - (win.h / 2),
            w = win.w,
            h = win.h,
         }
      end
   end,
   down = function (scr, win)
      local syc = scr.y + ((scr.h - scr.y) / 2)
      local wyc = win.y + win.h / 2
      if wyc < (syc - overlap) then
         -- we're in the top half, push to the center
         return {
            x = win.x,
            y = syc - (win.h / 2),
            w = win.w,
            h = win.h,
         }
      else
         -- we're in the bottom half, push to the edge
         return {
            x = win.x,
            y = scr.y + (scr.h - win.h),
            w = win.w,
            h = win.h,
         }
      end
   end,
}

hs.hotkey.bind({"alt", "cmd"}, "Left", function()
      local win = hs.window.focusedWindow()
      win:setFrame(move.left(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Right", function()
      local win = hs.window.focusedWindow()
      win:setFrame(move.right(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Up", function()
      local win = hs.window.focusedWindow()
      win:setFrame(move.up(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Down", function()
      local win = hs.window.focusedWindow()
      win:setFrame(move.down(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"cmd", "ctrl"}, "1", function() hs.osascript.applescript([[
tell application "Finder"
    activate
end tell
]]) end)

hs.hotkey.bind({"cmd", "ctrl"}, "2", function() hs.osascript.applescript([[
tell application "Firefox"
   activate
end tell
]]) end)

hs.hotkey.bind({"cmd", "ctrl"}, "3", function() hs.osascript.applescript([[
tell application "Terminal"
      activate
end tell
]]) end)
