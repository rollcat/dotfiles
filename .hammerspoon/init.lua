-- TODO: annotations for luals?
assert(hs, "Run this code in Hammerspoon")

-- resize

local resize_steps_up = { 0.25, 0.35, 0.5, 0.65, 1 }
local resize_steps_down = { 1, 0.65, 0.5, 0.35, 0.25 }
local resize = {
   -- grow or shrink the window horizontally
   growh = function(scr, win)
         for _, step in ipairs(resize_steps_up) do
            if (scr.w * step * 0.9) > win.w then
               win.w = scr.w * step
               break
            end
         end
         if win.w + win.x > scr.w + scr.x then
            win.x = scr.x + (scr.w - win.w)
         end
         return win
    end,
    shrinkh = function(scr, win)
         for _, step in ipairs(resize_steps_down) do
            if (scr.w * step * 1.1) < win.w then
                win.w = scr.w * step
                break
            end
      end
      return win
   end,
   -- grow or shrink the window horizontally
   growv = function(scr, win)
         for _, step in ipairs(resize_steps_up) do
            if (scr.h * step * 0.9) > win.h then
               win.h = scr.h * step
               break
            end
         end
         if win.h + win.y > scr.h + scr.y then
            win.y = scr.y + (scr.h - win.h)
         end
         return win
    end,
    shrinkv = function(scr, win)
         for _, step in ipairs(resize_steps_down) do
            if (scr.h * step * 1.1) < win.h then
                win.h = scr.h * step
                break
            end
      end
      return win
   end,
}

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(resize.growh(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(resize.shrinkh(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Down", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(resize.growv(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Up", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(resize.shrinkv(win:screen():frame(), win:frame()))
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
      if not win then return end
      win:setFrame(move.left(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Right", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(move.right(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Up", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(move.up(win:screen():frame(), win:frame()))
end)

hs.hotkey.bind({"alt", "cmd"}, "Down", function()
      local win = hs.window.focusedWindow()
      if not win then return end
      win:setFrame(move.down(win:screen():frame(), win:frame()))
end)

for i = 1, 9 do
  local cmd = string.format([[
    tell application "System Events"
      tell process "Dock"
        set frontmost to true
        activate
        click UI element %d of list 1
      end tell
    end tell
  ]], i)
  hs.hotkey.bind({"cmd", "ctrl"}, "" .. i, function() hs.osascript.applescript(cmd) end)
end
