return function(c, data, cb)
    local rData = require("decode")(data)
    local _, _, rConf = string.find(rData, "config=(.+)")
    local succ = false
    local wifiChanged = false

    if rConf then
        local updConf = cjson.decode(rConf)

        local newConf = {}
        newConf.ssid = updConf.ssid

        if updConf.ssid ~= _G["cfg"].ssid then
            wifiChanged = true
        end
        if (updConf.pass and #updConf.pass >= 8) then
            wifiChanged = true newConf.pass = updConf.pass else newConf.pass = _G["cfg"].pass
        end
        newConf.ip = updConf.ip
        newConf.port = updConf.port
        local newBright = {}
        if updConf.bright then
            local cbr = tonumber(updConf.bright.r)
            if (cbr and (cbr >= 0) and cbr <= 100) then
                newBright.r = cbr else newBright.r = 0;
            end
            cbr = tonumber(updConf.bright.y)
            if (cbr and (cbr >= 0) and cbr <= 100) then
                newBright.y = cbr else newBright.y = 0;
            end
            cbr = tonumber(updConf.bright.g)
            if (cbr and (cbr >= 0) and cbr <= 100) then
                newBright.g = cbr else newBright.g = 0;
            end
            newConf.bright = newBright
        end
        newConf.sound = updConf.sound
        newConf.ignoredIds = updConf.ignoredIds
        updConf = nil

        local k, serNCfg = pcall(cjson.encode, newConf)
        if k then
            -- save cfg into file
            file.open("cfg", "w")
            if pcall(file.writeline, serNCfg) then
                _G["cfg"] = newConf
                succ = true
            end
            file.close()
            serNCfg = nil
        end
    end

    require("clear")()

    local snd = require("sender")
    local redirectJs = "<script type='text/javascript'>setTimeout(function(){window.location.href='/'},2000);</script>"
    if succ then
        snd(c, "<div>Saved</div>" .. redirectJs,
            function(c)
                c:close()
                c:on("disconnection",
                    function(c)
                        if wifiChanged then
                            --require("wifi_con")()
                        end
                        require("send_conf")()
                    end)
            end)
    else
        snd(c, "<div>Err</div>" .. redirectJs)
    end
end