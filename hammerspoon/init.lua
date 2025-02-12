-- Hammerspoon initialization file

-- Keyboard shortcuts
--open Terminal ctrl + cmd + T
hs.hotkey.bind({"ctrl", "cmd"}, "T", function()
    hs.application.open('Terminal.app')
end)
