QuickChat = {}; 

----------------------
--INITIATE VARIABLES--
----------------------

QuickChat.name = "QuickChat";
QuickChat.version = "1.00";
QuickChat.settingName = "Quick Chat"
QuickChat.settingDisplayName = "RockingDice's QuickChat"
QuickChat.author = "RockingDice"
QuickChat.maxGroupNum = 15
QuickChat.maxChatNum = 15
QuickChat.SELECT_GROUP_MODE = 0
QuickChat.SELECT_CHAT_MODE = 1

QuickChat.ICON_TYPE_CANCEL = -100
QuickChat.ICON_TYPE_GROUP = -101
QuickChat.ICON_TYPE_CHAT = -102

QuickChat.presets = { 
	exitAfterSend = false,
	currentGroupIndex = 1,
	groups = {
		[1] = 1,
		[2] = 2,
		[3] = 3, 
	},
	groupsCount = 7,
	groupsData = {
		{
			groupName = "Common",
			chatData = {
				"Hello",
				"Hi",
				"Goodbye",
				"Yes",
				"No",
				"Thank you",
				"You're welcome",
				"Sorry",
				"Group up?",
				"Good job",
			}, 
			chatEntriesCount = 10,
		},
		{
			groupName = "Group",
			chatData = {
				"Vet",
				"Normal",
				"Dps",
				"Healer",
				"Tank",
				"Dragonknight",
				"Nightblade",
				"Sorcerer",
				"Templar",
				"Warden",
			},
			chatEntriesCount = 10,
		},
		{
			groupName = "Dungeon",
			chatData = {
				"ty",
				"tyfg",
				"gg",
				"gj",
				"nvm",
				"hs",
				"chest",
				"brb",
				"afk",
				"gtg",
				"sorry",
				"lag",
				"check for food",
				"ok",
				"no",
			},
			chatEntriesCount = 15,
		},
		{
			groupName = "Battle", 
			chatData = {
				"Heal Me",
				"Low on Magicka",
				"Low on Stamina",
				"Spread out",
				"Get close",
				"Attack the boss",
				"Is everyone ready?",
				"Handle the odds",
				"Synergy",
				"Move away",
				"Pulling",
				"Tank the boss",
				"Ignore the adds",
			}, 
			chatEntriesCount = 13,
		},
		{
			groupName = "Trade",
			chatData = {
				"I want to buy",
				"I want to sell",
				"How much?",
				"Deal",
				"Trade or COD?",
				"Trade",
				"COD",
				"Okay",
				"No, thank you",
			}, 
			chatEntriesCount = 9,
		},
		{
			groupName = "Emote 1",
			chatData = {
				"/bless",
				"/bow",
				"/pray",
				"/cheer",
				"/taunt",
				"/shakefist",
				"/angry",
				"/laugh",
			}, 
			chatEntriesCount = 8,
		},
		{
			groupName = "Emote 2",
			chatData = {
				"/lute",
				"/flute",
				"/drum",
				"/dance",
				"/cold",
				"/faint",
				"/torch",
				"/huh",
			}, 
			chatEntriesCount = 8,
		},
	}
}

QuickChat.menuChoices = {} 
QuickChat.menuChoicesShowNames = {}
for i = 1, QuickChat.maxGroupNum do 
	table.insert(QuickChat.menuChoices, i)
end

QuickChat.emoteSlashNameMap = {}
QuickChat.emoteIndexMap = {}
QuickChat.emoteCategoryArray = {}
local numEmotes = GetNumEmotes()
for i = 1, numEmotes do
	local slashName, category, _ , displayName = GetEmoteInfo(i)
	QuickChat.emoteSlashNameMap[slashName] = i
	QuickChat.emoteIndexMap[i] = { slashName = slashName, displayName = displayName, category = category }
	if not QuickChat.emoteCategoryArray[category] then
		QuickChat.emoteCategoryArray[category] = {}
	end
	table.insert(QuickChat.emoteCategoryArray[category], {index = i, name = displayName})
end
 
QuickChat.KEYBOARD_MENU_ENTRIES =
{
    [QuickChat.ICON_TYPE_CANCEL] =
    {
        enabledNormal = "EsoUI/Art/HUD/radialIcon_cancel_up.dds",
    },  
	[QuickChat.ICON_TYPE_GROUP] =
    {
		enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_cadwell_up.dds", 
	},
	[QuickChat.ICON_TYPE_CHAT] =
    {
        enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_up.dds",
    },  
    [EMOTE_CATEGORY_CEREMONIAL] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_ceremonial_up.dds",
    },
    [EMOTE_CATEGORY_CHEERS_AND_JEERS] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_cheersJeers_up.dds",
    },
    [EMOTE_CATEGORY_EMOTION] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_emotion_up.dds",
    },
    [EMOTE_CATEGORY_ENTERTAINMENT] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_entertain_up.dds",
    },
    [EMOTE_CATEGORY_FOOD_AND_DRINK] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_eatDrink_up.dds",
    },
    [EMOTE_CATEGORY_GIVE_DIRECTIONS] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_directions_up.dds",
    },
    [EMOTE_CATEGORY_PERPETUAL] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_perpetual_up.dds",
    },
    [EMOTE_CATEGORY_PHYSICAL] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_physical_up.dds",
    },
    [EMOTE_CATEGORY_POSES_AND_FIDGETS] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_fidget_up.dds",
    },
    [EMOTE_CATEGORY_PROP] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_prop_up.dds",
    },
    [EMOTE_CATEGORY_SOCIAL] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_social_up.dds",
    },
    [EMOTE_CATEGORY_PERSONALITY_OVERRIDE] = {
        enabledNormal = "EsoUI/Art/Emotes/emotes_indexIcon_personality_up.dds",
    },
    [EMOTE_CATEGORY_COLLECTED] = {
        enabledNormal = "EsoUI/Art/Collections/collections_tabIcon_collectibles_up.dds",
    },
}


QuickChat.GAMEPAD_MENU_ENTRIES =
{
     [QuickChat.ICON_TYPE_CANCEL] =
    {
        enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
    },  
	[QuickChat.ICON_TYPE_GROUP] =
    { 
		enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_cadwell_up.dds", 
	},
	[QuickChat.ICON_TYPE_CHAT] =
    {
        enabledNormal = "esoui/art/emotes/gamepad/gp_emoteicon_quickchat.dds",
    },  
    [EMOTE_CATEGORY_CEREMONIAL]         = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_ceremonial.dds", },
    [EMOTE_CATEGORY_CHEERS_AND_JEERS]   = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_cheersJeers.dds", },
    [EMOTE_CATEGORY_EMOTION]            = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_emotion.dds", },
    [EMOTE_CATEGORY_ENTERTAINMENT]      = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_entertain.dds", },
    [EMOTE_CATEGORY_FOOD_AND_DRINK]     = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_eatDrink.dds", },
    [EMOTE_CATEGORY_GIVE_DIRECTIONS]    = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_direction.dds", },
    [EMOTE_CATEGORY_PERPETUAL]          = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_perpetual.dds", },
    [EMOTE_CATEGORY_PHYSICAL]           = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_physical.dds", },
    [EMOTE_CATEGORY_POSES_AND_FIDGETS]  = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_fidget.dds", },
    [EMOTE_CATEGORY_PROP]               = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_prop.dds", },
    [EMOTE_CATEGORY_SOCIAL]             = { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_social.dds", },
	[EMOTE_CATEGORY_PERSONALITY_OVERRIDE]= { enabledNormal = "EsoUI/Art/Emotes/Gamepad/gp_emoteIcon_personality.dds", },
    [EMOTE_CATEGORY_COLLECTED]          = { enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds", },
	 
}
 
function QuickChat.GetGroupArrayIndex(slotIndex)
	if QuickChat.acctSavedVariables.groups[slotIndex] == nil then
		QuickChat.acctSavedVariables.groups[slotIndex] = slotIndex
	end
	return QuickChat.acctSavedVariables.groups[slotIndex]
end

function QuickChat.GetGroup(groupIndex)
	if QuickChat.acctSavedVariables.groupsData[groupIndex] == nil then 
		local newGroupData = 
		{
			groupName = "NewGroup",
			chatData = {
			}, 
			chatEntriesCount = 8,
		}
		newGroupData.groupName = "NewGroup" .. groupIndex
 		QuickChat.acctSavedVariables.groupsData[groupIndex] = newGroupData
	end
	return QuickChat.acctSavedVariables.groupsData[groupIndex]
end 

function QuickChat.GetChatData(groupData, index)
	if groupData.chatData[index] == nil then
		groupData.chatData[index] = ""
	end
	return groupData.chatData[index]
end