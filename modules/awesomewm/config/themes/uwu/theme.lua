-- vim:fdm=marker
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local dpi = require("beautiful.xresources").apply_dpi

-- Theme Definition {{{
local theme = {}
theme.dir = os.getenv("HOME").."/.config/awesome/themes/uwu/"

-- Fonts
theme.font = "Iosevka Nerd Font 9"
theme.taglist_font = "FiraMono Nerd Font Mono 20"
theme.icon_font = "Iosevka Nerd Font 10"
theme.exit_screen_font = "FiraMono Nerd Font Mono 120"
theme.widget_font = 'Sans 10'
theme.notification_font = "Sans 10"
theme.tasklist_font = "Roboto 10"

-- colors
theme.clr = {
	purple = "#c792ea",
	blue = "#82aaff",
	green = "#7cd380",
	red = '#ff5370',
	gray = '#8796b0',
	yellow = '#ffcb8b',
	pink = '#FF68C4',
	white = '#8dd1de',
	cyan = '#88c0d0',
	orange = '#ffbd2e'
}

theme.fg_normal = '#424760'
theme.fg_focus = '#a6accd'
theme.fg_urgent = '#424760'

theme.bg_normal = '#1e222a'
theme.bg_focus = '#121622'
theme.bg_urgent = "#081218"
theme.bg_light = '#2c3038'
theme.bg_systray = theme.bg_light

theme.tasklist_bg_normal = '#181828'
theme.tasklist_bg_focus = '#1f1f2f'
theme.tasklist_bg_urgent = '#1b1b2b'

theme.taglist_bg_urgent = "#2f2f3f"
theme.taglist_bg_focus = "#2f2f3f"
theme.taglist_fg_occupied = theme.clr.blue
theme.taglist_fg_urgent = theme.clr.red
theme.taglist_fg_empty = theme.clr.gray
theme.taglist_fg_focus = theme.clr.green

theme.notification_fg = '#a6accd'
theme.notification_bg = '#121622'
theme.notification_opacity = 1

theme.useless_gap   = dpi(2)
theme.border_width  = dpi(1)
theme.border_normal = "#000000"
theme.border_focus  = "#6272a4"
theme.border_marked = "#91231c"

theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.gap_single_client = false

-- naughty configuration
theme.notification_border_color = theme.bg_light
theme.notification_border_width = dpi(5)

naughty.config.padding = dpi(8)
naughty.config.defaults = {
	timeout = 5,
	text = "",
	ontop = true,
	position = "top_right",
	margin = dpi(10),
}

-- }}}

-- widgets {{{
-- Clock
local clockicon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'"> </span>', theme.clr.purple)
)
local clock = wibox.widget.textclock(
	'<span font="'..theme.widget_font..'" color="'..theme.clr.purple..'"> %R</span>'
)

-- Calendar
local calendaricon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'"> </span>', theme.clr.yellow)
)
local calendar = wibox.widget.textclock(
	'<span font="'..theme.widget_font..'" color="'..theme.clr.yellow..'"> %-d %b %Y (%a)</span>'
)

-- Battery
local baticon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'">  </span>', theme.clr.blue)
)
local bat = awful.widget.watch([[bash -c "echo $(cat /sys/class/power_supply/BAT0/capacity)%"]], 60, function(widget, stdout)
		widget:set_markup('<span color="'..theme.clr.blue..'" font="'..theme.widget_font..'"> ' ..stdout.."%</span> ")
end)

-- CPU
local cpuicon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'"> </span>', theme.clr.pink)
)
local cpu = awful.widget.watch([[bash -c "echo `top -b -n1 | grep \"Cpu(s)\" | awk '{print $2 + $4}'`%"]], 3, function(widget, stdout)
		widget:set_markup('<span color="'..theme.clr.pink..'" font="'..theme.widget_font..'"> ' ..stdout.."%</span> ")
end)

-- Temperature
local tempicon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'"> </span>', theme.clr.yellow)
)
local temp = awful.widget.watch([[bash -c "echo `cat /sys/devices/virtual/thermal/thermal_zone0/temp | awk '{print $1 / 1000}'` °C"]], 5, function(widget, stdout)
		widget:set_markup('<span color="'..theme.clr.yellow..'" font="'..theme.widget_font..'"> ' ..stdout.."%</span> ")
end)

-- mem
local memicon = wibox.widget.textbox(
	string.format('<span color="%s" font="'..theme.icon_font..'"> </span>', theme.clr.cyan)
)
local mem = awful.widget.watch([[bash -c "echo `free -m | grep Mem | awk '{print $3}'` MB"]], 3, function(widget, stdout)
		widget:set_markup('<span color="'..theme.clr.cyan..'" font="'..theme.widget_font..'"> ' ..stdout.."%</span> ")
end)

-- Volume control
local vol = wibox.widget {
		max_value     = 100,
		value         = 25,
		forced_width  = 100,
		forced_height = 2,
		border_width  = 2,
		color         = theme.clr.green,
		background_color = "#565c64",
		shape     = gears.shape.rounded_bar,
		margins       = {
				top    = 8,
				bottom = 8,
		},
		widget        = wibox.widget.progressbar,
}
local volicon = wibox.widget.textbox('')
theme.update_volume = function()
	awful.spawn.easy_async_with_shell([[
		printf "%s" $(pamixer --get-volume)]], function(stdout)
		if stdout == "muted\n" then
			volicon:set_markup('<span color="'..theme.clr.green..'" font="'..theme.icon_font..'">婢 </span>')
		elseif stdout == "0%" then
			volicon:set_markup('<span color="'..theme.clr.green..'" font="'..theme.icon_font..'"> </span>')
			vol:set_markup('<span color="'..theme.clr.green..'" font="'..theme.widget_font..'"> '..stdout.."</span> ")
		else
			volicon:set_markup('<span color="'..theme.clr.green..'" font="'..theme.icon_font..'">墳 </span>')
			vol:set_value(tonumber(stdout))
		end
	end)
end

theme.update_volume()

-- Separators
local spr = wibox.widget.textbox('     ')
local half_spr = wibox.widget.textbox('  ')

-- power
local power_menu = { }
local power = wibox.widget.textbox('<span font="'..theme.icon_font..'" color="'..theme.clr.red..'"> </span>')

power:connect_signal("mouse::enter", function()
	power:set_markup('<span font="'..theme.icon_font..'" color="'..theme.clr.blue..'"> </span>')
end)

power:connect_signal("mouse::leave", function()
	power:set_markup('<span font="'..theme.icon_font..'" color="'..theme.clr.red..'"> </span>')
end)

power:connect_signal("button::press", function()
	if power_menu.visible == nil then
		local logout = wibox.widget.textbox(
			'<span font="'..theme.exit_screen_font..'" color="'..theme.clr.purple..'"></span>'
		)

		local poweroff = wibox.widget.textbox(
			'<span font="'..theme.exit_screen_font..'" color="'..theme.clr.blue..'">⏻</span>'
		)

		local reboot = wibox.widget.textbox(
			'<span font="'..theme.exit_screen_font..'" color="'..theme.clr.green..'">ﰇ</span>'
		)

		local close = wibox.widget.textbox(
			'<span font="'..theme.exit_screen_font..'" color="'..theme.clr.red..'"></span>'
		)
		power_menu = awful.popup {
			ontop = true,
			visible = true,
			bg = theme.bg_light.."cc",
			fg = theme.fg_focus,
			placement = awful.placement.maximize,
			widget = {
				{
					{
						{
							{
								spr,
								layout = wibox.layout.fixed.horizontal,
							},
							widget = wibox.container.place,
						},
						{
							{
								spr, spr, spr,
								spr, spr,
								logout,
								spr, spr, spr,
								spr, spr,
								poweroff,
								spr, spr, spr,
								spr, spr,
								reboot,
								spr, spr, spr,
								spr, spr,
								layout = wibox.layout.fixed.horizontal,
							},
							widget = wibox.container.place,
						},
						{
							{
								close,
								layout = wibox.layout.align.horizontal,
							},
							widget = wibox.container.place,
						},
						layout = wibox.layout.fixed.vertical,
					},
					margins = dpi(20),
					widget = wibox.container.margin
				},
				widget = wibox.container.background,
			},
		}

		logout:connect_signal("button::press", function()
			awful.util.spawn("pkill X")
		end)

		poweroff:connect_signal("button::press", function()
			awful.util.spawn("shutdown now")
		end)

		reboot:connect_signal("button::press", function()
			awful.util.spawn("shutdown -r now")
		end)
		close:connect_signal("button::press", function()
			power_menu.visible = false
		end)
	else power_menu.visible = not power_menu.visible end
end)
-- }}}

-- load theme options {{{
function theme.at_screen_connect(s)
	gears.wallpaper.maximized(theme.dir.."/background.png", s)

	-- Tags
	awful.tag({'', '', '', '', '', '', '', '', ''}, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(awful.util.table.join(awful.button({}, 1, function()
		awful.layout.inc(1)
	end), awful.button({}, 2, function()
		awful.layout.set(awful.layout.layouts[1])
	end), awful.button({}, 3, function()
		awful.layout.inc(-1)
	end), awful.button({}, 4, function()
		awful.layout.inc(1)
	end), awful.button({}, 5, function()
		awful.layout.inc(-1)
	end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			shape = gears.shape.rounded_rect
		},
		layout = {
			spacing = 0,
			spacing_widget = {
				color = theme.fg_normal,
				shape = gears.shape.rounded_rect,
			},
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{
				{
					{
						bg = theme.fg_normal,
						shape = '',
						widget = wibox.container.background,
					},
					{
						{
							id = 'icon_role',
							widget = wibox.widget.imagebox,
						},
						margins = 0,
						widget = wibox.container.margin,
					},
					{
						id = 'text_role',
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.align.horizontal,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin
			},
			id = 'background_role',
			widget = wibox.container.background,
		},
		buttons = awful.util.taglist_buttons
	}

	s.mytasklist = awful.widget.tasklist {
	    screen  = s,
	    filter  = awful.widget.tasklist.filter.currenttags,
	    buttons = {
	        awful.button({ }, 1, function (c)
	            c:activate { context = "tasklist", action = "toggle_minimization" }
	        end),
	        awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
	        awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
	        awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
	    }
	}

	s.wibox = awful.wibar {
		height = dpi(20),
		screen = s,
		expand = true,
		visible = true,
		bg = theme.bg_normal,
	}
	s.wibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			{
				layout = wibox.layout.fixed.horizontal,
				{
					s.mytaglist,
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
			},
			widget = wibox.container.margin,
		},
		
		{ -- Center widgets
			layout = wibox.layout.align.horizontal,
			half_spr,
			s.mytasklist, -- Middle widget
		},
		{
			{
				
				-- Show CPU %
				-- {
				-- 	{
				-- 		layout = wibox.layout.fixed.horizontal,
				-- 		half_spr,
				-- 		cpuicon,
				-- 		cpu,
				-- 		half_spr,
				-- 	},
				-- 	bg = theme.bg_light,
				-- 	shape = gears.shape.rounded_rect,
				-- 	widget = wibox.container.background,
				-- },
				-- half_spr,

				-- Show memmory
				-- {
				-- 	{
				-- 		layout = wibox.layout.fixed.horizontal,
				-- 		half_spr,
				-- 		memicon,
				-- 		mem,
				-- 		half_spr,
				-- 	},
				-- 	bg = theme.bg_light,
				-- 	shape = gears.shape.rounded_rect,
				-- 	widget = wibox.container.background,
				-- },
				-- half_spr,
				-- {
				-- 	{
				-- 		layout = wibox.layout.fixed.horizontal,
				-- 		half_spr,
				-- 		tempicon,
				-- 		temp,
				-- 		half_spr,
				-- 	},
				-- 	bg = theme.bg_light,
				-- 	shape = gears.shape.rounded_rect,
				-- 	widget = wibox.container.background,
				-- },
				-- half_spr,
				{
					{
						layout = wibox.layout.fixed.horizontal,
						half_spr,
						volicon,
						vol,
						half_spr,
					},
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
				half_spr,
				{
					{
						layout = wibox.layout.fixed.horizontal,
						half_spr,
						baticon,
						bat,
						half_spr,
					},
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
				half_spr,
				{
					{
						layout = wibox.layout.fixed.horizontal,
						half_spr,
						calendaricon,
						calendar,
						half_spr
					},
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
				half_spr,
				layout = wibox.layout.fixed.horizontal,
				{
					{
						layout = wibox.layout.fixed.horizontal,
						half_spr,
						clockicon,
						clock,
						half_spr
					},
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
				half_spr,
				{
					{
						layout = wibox.layout.align.horizontal,
						half_spr,
						power,
						half_spr
					},
					widget = wibox.container.background,
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect
				},
				half_spr,
				{
					{
						layout = wibox.layout.fixed.horizontal,
						half_spr,
						wibox.widget.systray(),
						half_spr,
					},
					bg = theme.bg_light,
					shape = gears.shape.rounded_rect,
					widget = wibox.container.background,
				},
			},
			widget = wibox.container.margin,
		},
	}
end
-- }}}

return theme
