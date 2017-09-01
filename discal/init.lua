--- textclock that can also display discordian date
-- based heavily on lib.wibox.widget.textclock

local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local spawn = require("awful.spawn")
local beautiful = require("beautiful")

local discal = { mt = {} }

discal.needs_the_d = false

local function calc_timeout(real_timeout)
    return real_timeout - os.time() % real_timeout
end

function discal.new(format, timeout, fg, bg)
    format = format or {}
    timeout = timeout or 60
    fg = fg or beautiful.taglist_fg_focus or "#ffffff"
    bg = bg or beautiful.taglist_bg_empty or "#000000"

    local w = textbox()
    w.i_need_the_d = discal.needs_the_d or false
    local t
    function w._private.discal_update_cb()
        if w.i_need_the_d then 
            cmd = "ddate"
            fmt = format.ddate or ""
        else 
            cmd = "date"
            fmt = format.date or "%A %e %B"
        end
        spawn.easy_async(cmd..(#fmt > 0 and " +'"..fmt.."'" or fmt),
            function (stdout)
                w:set_markup("<span background='"..bg
                             .."' foreground='"..fg.."'>"
                             .. stdout .. "</span>")
            end)
        t.timeout = calc_timeout(timeout)
        t:again()
        return true -- Continue the timer
    end
    t = timer.weak_start_new(timeout, w._private.discal_update_cb)
    t:emit_signal("timeout")
    return w
end

function discal.toggle(widget)
    widget.i_need_the_d = not widget.i_need_the_d
    widget._private.discal_update_cb()
end

function discal.mt:__call(...)
    return discal.new(...)
end

return setmetatable(discal, discal.mt)
