local extension = Package:new("dms")
extension.extensionName = "freekill-ext-zyb"

local U = require "packages/utility/utility"

Fk:loadTranslationTable {
    ["freekill-ext-zyb"] = "枣院定制",
    ["dms"] = "动漫社"
}

--#region 阿伟
local awei = General(extension, "awei", "shu", 4)
Fk:loadTranslationTable {
    ["awei"] = "阿伟",
    ["#awei"] = "南通圣体",
    ["designer:awei"] = "一纸",
    ["cv:awei"] = "没有",
    ["illustrator:awei"] = "阿伟帅照",
}

--#region 阿伟技能 攻
local awei_gong = fk.CreateViewAsSkill {
    name = "awei_gong",
    pattern = "duel",
    card_filter = function(self, to_select, selected)
        if #selected == 1 then return false end
        return Fk:getCardById(to_select).type == Card.TypeBasic
        -- return string.find(Fk:getCardById(to_select).name, "slash") ~= nil
    end,
    view_as = function(self, cards)
        if #cards ~= 1 then
            return nil
        end
        local c = Fk:cloneCard("duel")
        c.skillName = self.name
        c:addSubcard(cards[1])
        return c
    end,
    before_use = function(self, player, use)
        player.room:removePlayerMark(player, "@awei_nantong", 1)
    end,
    after_use = function(self, player, use)
        -- 造成伤害后可以获取对方的一张手牌
        -- player.room:addPlayerMark(player, "@ceshi", 1)
        local room = player.room
        local target = player.room:getPlayerById(TargetGroup:getRealTargets(use.tos)[1])

        if not player.dead and not target.dead and use.damageDealt and use.damageDealt[target.id] then
            local cards = U.askforCardsChosenFromAreas(player, target, "h", self.name, nil, nil, false)
            if #cards > 0 then
                room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
            end
        end
    end,
    enabled_at_play = function(self, player)
        if player:getMark("@awei_nantong") > 0 then
            return true
        else
            return false
        end
    end
}

local awei_gong_trig = fk.CreateTriggerSkill {
    name = "#awei_gong_trig",
    events = { fk.TurnStart },
    frequency = Skill.Compulsory,
    can_trigger = function(self, event, target, player, data)
        return target == player and target:hasSkill(self)
    end,
    on_use = function(self, event, target, player, data)
        player.room:addPlayerMark(player, "@awei_nantong", 1)
    end,
}

awei_gong:addRelatedSkill(awei_gong_trig)

Fk:loadTranslationTable {
    ["awei_gong"] = "攻",
    [":awei_gong"] = "回合开始时获得一枚标记，你可以弃置一枚标记将任意基本牌当做决斗使用，造成伤害后可以获取对方的一张手牌。",
    ["@awei_nantong"] = "南通",
    ["#awei_gong_trig"] = "南通 +1",
}
--#endregion

--#region 阿伟技能 受
local awei_shou = fk.CreateTriggerSkill {
    name = "awei_shou",
    events = { fk.Damaged },
    frequency = Skill.Compulsory,
    can_trigger = function(self, event, target, player, data)
        return player == target and target:hasSkill(self)
    end,
    on_use = function(self, event, player, data)
        player.room:addPlayerMark(player, "@awei_nantong", 1)
    end,
}

Fk:loadTranslationTable {
    ["awei_shou"] = "受",
    [":awei_shou"] = "当你受到伤害时，额外获得一枚南通标记",
    ["#awei_shou_be_dueled"] = "受 被动触发",
}
--#endregion

awei:addSkill(awei_gong)
awei:addSkill(awei_shou)

--#endregion

return extension
