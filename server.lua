
----------------------------------------- By Dracula Discord : dracula.1111 : server : https://discord.gg/nq86k9dGYS ----------------------------------------- 


-- لا تعدل عليه
Citizen.CreateThread(function()
    Wait(1000) 

   -- لا تعدل عليه
    local createTableQuery = [[
    CREATE TABLE IF NOT EXISTS vrpfx.user_playtime (
        discord_id VARCHAR(100) NOT NULL,
        playtime BIGINT NOT NULL DEFAULT 0,
        last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (discord_id)
    );
    ]]
-- لا تعدل عليه
    exports['oxmysql']:execute(createTableQuery, {}, function(affectedRows)
        if affectedRows then
            print("تم إنشاء جدول وقت اللعب بنجاح.")
        else
            print("حدث خطأ أثناء إنشاء جدول وقت اللعب.")
        end
    end)
end)

-- لا تعدل عليه
local playerLoginTime = {}

-- لا تعدل عليه
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in pairs(identifiers) do
        if string.sub(id, 1, 8) == "discord:" then
            playerLoginTime[id] = os.time()
            break
        end
    end
end)

-- لا تعدل عليه
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in pairs(identifiers) do
        if string.sub(id, 1, 8) == "discord:" then
            if playerLoginTime[id] then
                local playTimeInSeconds = os.time() - playerLoginTime[id]
                local updateQuery = [[
                    INSERT INTO user_playtime (discord_id, playtime)
                    VALUES (?, ?)
                    ON DUPLICATE KEY UPDATE playtime = playtime + ?, last_login = CURRENT_TIMESTAMP;
                ]]
                exports['oxmysql']:execute(updateQuery, {id, playTimeInSeconds, playTimeInSeconds})
            end
            break
        end
    end
end)


----------------------------------------- By Dracula Discord : dracula.1111 : server : https://discord.gg/nq86k9dGYS ----------------------------------------- 

local WebhookURL = "https://discord.com/api/webhooks/1221604884994986055/KX2A_1oP_NWpjbS_J6UBgcfY94LFoEg5sG6xfH8mDZtJ0hPIqfHsgqBnoV-_995aExA7" -- حط رابط الويب هوك
function secondsToHoursMinutes(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local hoursMinutes = hours + minutes / 60
    return string.format("%.2f", hoursMinutes) 
end

-- لا تعدل عليه
function fetchTopPlayersAndSendEmbed()
    local query = [[
        SELECT discord_id, playtime
        FROM vrpfx.user_playtime
        ORDER BY playtime DESC
        LIMIT 10;
    ]]
    
    exports['oxmysql']:execute(query, {}, function(results)
        if results and #results > 0 then
            local embeds = {{
                author = {
                    name = "#top 10", 
                },
                color = 0xf1c40f,
                fields = {},
                footer = {
                    text = "DR Store", -- اسم السيرفر
                    icon_url = "https://cdn.discordapp.com/attachments/1217626820350967959/1221992726707306526/96x96.gif" -- رابط صورة السيرفر
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
            for i, player in ipairs(results) do
                local hoursMinutes = secondsToHoursMinutes(player.playtime)
                local discordMention = player.discord_id and "<@"..string.sub(player.discord_id, 9)..">" or "غير معرف"
                table.insert(embeds[1].fields, {
                    name = string.format("#%d", i),
                    value = string.format("%s : %s hours :star:", discordMention,  hoursMinutes), 
                    inline = true 
                })
            end                
            
            local messageData = {
                username = "DR Store", -- اسم سيرفرك
                embeds = embeds
            }
            
            PerformHttpRequest(WebhookURL, function(err, text, headers)
                if err ~= 200 then
                    print("فشل في إرسال إمبد إلى Discord. كود الخطأ: " .. err)
                else
                    print("تم إرسال الإمبد بنجاح.")
                end
            end, 'POST', json.encode(messageData), {['Content-Type'] = 'application/json'})
        else
            print("لم يتم العثور على بيانات لإرسالها.")
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        fetchTopPlayersAndSendEmbed()
        Citizen.Wait(604800000) 
    end
end)

-- 604800000 اسبوع 
-- 86400 يوم كامل 24 ساعه
-- 172800 يومين 48 ساعه
-- 259200 ثلاث أيام 72 ساعه