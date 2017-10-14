
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

local selectedEditGroup = 1
local selectedEditEntry = 1



local function GetSelectedGroup()
	return QuickChat.GetGroup(selectedEditGroup)
end

local emoteChoices = {}
local emoteChoicesShowNames = {}
local function RefreshEmoteData()
	emoteChoices = {}
	emoteChoicesShowNames = {}
	table.insert(emoteChoices, 0)
	table.insert(emoteChoicesShowNames, "No Emote")
	for i = EMOTE_CATEGORY_CEREMONIAL, EMOTE_CATEGORY_COLLECTED do
		if QuickChat.emoteCategoryArray[i] then
			--add category entry
			local categoryName = GetString("SI_EMOTECATEGORY", i)
			table.insert(emoteChoices, -1)
			table.insert(emoteChoicesShowNames, string.format("[ %s ]", categoryName))
			
			--add emotes
			for k = 1, #QuickChat.emoteCategoryArray[i] do
				local data = QuickChat.emoteCategoryArray[i][k]
				table.insert(emoteChoices, data.index)
				table.insert(emoteChoicesShowNames, zo_strformat("   |cFFE690<<1>>|r", data.name))
			end
		end
	end
end

local function RefreshGroupNames()
	QuickChat.menuChoicesShowNames = {}
	for i = 1, QuickChat.maxGroupNum do
		table.insert(QuickChat.menuChoicesShowNames, QuickChat.GetGroup(i).groupName)
	end
end
  
local function UpdateGroupDropDown(name) 
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name, "")  
	dropdownCtrl:UpdateChoices(QuickChat.menuChoicesShowNames, QuickChat.menuChoices)  
end

local function UpdateAllGroupDropDowns()
	for i = 1, QuickChat.maxGroupNum do
		UpdateGroupDropDown("QC_DROPDOWN_GROUP" .. i)
	end
	UpdateGroupDropDown("QC_DROPDOWN_GROUP_EDIT")
end

local chatEntryChoices = {}
local chatEntryChoicesShowNames = {}
local function RefreshSelectedChatEntryData()
	chatEntryChoices = {}
	chatEntryChoicesShowNames = {}
	local group = GetSelectedGroup()
	for i = 1, group.chatEntriesCount do
		table.insert(chatEntryChoices, i)
		table.insert(chatEntryChoicesShowNames, zo_strformat("(<<1>>) |cFFE690<<2>>|r", i, QuickChat.GetChatData(group, i)))
	end
end
local function UpdateChatEntryDropDown()
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName("QC_DROPDOWN_CHAT_ENTRY", "")  
	dropdownCtrl:UpdateChoices(chatEntryChoicesShowNames, chatEntryChoices)
end

function QuickChat.AddonMenuInit()   
	RefreshGroupNames()
	RefreshEmoteData()
	RefreshSelectedChatEntryData()
	
	local panelData =  {
		type = "panel",
		name = QuickChat.settingName,
		displayName = QuickChat.settingDisplayName,
		author = QuickChat.author,
		version = QuickChat.version,
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() 
			QuickChat.ResetToDefaults() 
			RefreshGroupNames()
			UpdateAllGroupDropDowns()
		end,
	}
	local groups = {
	}
	local chats = {
	} 
	for i=1, QuickChat.maxGroupNum do
		local slotdata = {}
		slotdata.type = "dropdown"
		slotdata.name = string.format("Group %d", i)
		slotdata.scrollable = true
		slotdata.choices = QuickChat.menuChoicesShowNames
		slotdata.choicesValues = QuickChat.menuChoices
		slotdata.getFunc = function() 
			return QuickChat.GetGroupArrayIndex(i)
		end
		slotdata.setFunc = function(value)
			QuickChat.acctSavedVariables.groups[i] = value	
		end
		slotdata.width = "full" 
		slotdata.disabled = function()
			return i > QuickChat.acctSavedVariables.groupsCount
		end
		slotdata.reference = "QC_DROPDOWN_GROUP" .. i
		table.insert(groups, slotdata)		
	end
	for i=1, QuickChat.maxChatNum do
		local slotdata = {}
		slotdata.type = "editbox"
		slotdata.name = string.format("Chat Entry %d", i)
		slotdata.getFunc = function()  
			return QuickChat.GetChatData(GetSelectedGroup(), i)
		end
		slotdata.setFunc = function(v)
			GetSelectedGroup().chatData[i] = v 
			RefreshSelectedChatEntryData()
			UpdateChatEntryDropDown()
		end 
		slotdata.isMultiline = false
		slotdata.width = "full"
		slotdata.disabled = function()
			return i > GetSelectedGroup().chatEntriesCount
		end
		table.insert(chats, slotdata)		
	end
	local optionsTable = { 
		{
			type = "header",
			name = "Chat Group Setting",
		},
		{
			type = 'slider',
			name = "Chat Groups Count",
			min = 1,
			max = QuickChat.maxGroupNum,
			getFunc = function()
				return QuickChat.acctSavedVariables.groupsCount
			end,
			setFunc = function(v)
				QuickChat.acctSavedVariables.groupsCount = v
			end,
		},
		{
			type = "submenu",
			name = "Chat Groups",
			controls = groups,
		},
		
		{
			type = "header",
			name = "Chat Entry Setting",
		},
		{
			type = "dropdown",
			name = "Select Chat Group",
			scrollable = true,
			choices = QuickChat.menuChoicesShowNames,
			choicesValues = QuickChat.menuChoices,
			getFunc = function()
				return selectedEditGroup
			end,
			setFunc = function(v)
				selectedEditGroup = v
				selectedEditEntry = 1
				RefreshSelectedChatEntryData()
				UpdateChatEntryDropDown()
			end,
			width = "full", 
			reference = "QC_DROPDOWN_GROUP_EDIT"
		},
		{
			type = "editbox",
			name = "Group Name", 
			getFunc = function() 
				return GetSelectedGroup().groupName 
			end,
			setFunc = function(v) 
				GetSelectedGroup().groupName = v 
				RefreshGroupNames()
				UpdateAllGroupDropDowns()
			end, 
			isMultiline = false,  
			width = "full", --or "half" (optional) 
		},
		{
			type = 'slider',
			name = "Chat Entries Count",
			min = 1,
			max = QuickChat.maxChatNum,
			getFunc = function()
				return GetSelectedGroup().chatEntriesCount 
			end,
			setFunc = function(v)
				GetSelectedGroup().chatEntriesCount  = v
				RefreshSelectedChatEntryData()
				UpdateChatEntryDropDown()
			end,
		},
		{
			type = "submenu",
			name = "Chat Entries",
			controls = chats,
		},
		{
			type = "submenu",
			name = "Emote Editor",
			controls = {
				{
					type = "dropdown",
					name = "Select Chat Entry",
					scrollable = true,
					choices = chatEntryChoicesShowNames,
					choicesValues = chatEntryChoices,
					getFunc = function()
						return selectedEditEntry
					end,
					setFunc = function(v)
						selectedEditEntry = v
					end,
					width = "full", 
					reference = "QC_DROPDOWN_CHAT_ENTRY"
				},
				{
					type = "dropdown",
					name = "Emote",
					scrollable = true,
					choices = emoteChoicesShowNames,
					choicesValues = emoteChoices,
					getFunc = function()
						local chatData = QuickChat.GetChatData(GetSelectedGroup(), selectedEditEntry)
						local emoteIndex = QuickChat.emoteSlashNameMap[chatData]
						if emoteIndex then
							--find emote
							return emoteIndex
						end
						return 0
					end,
					setFunc = function(v)
						if v ~= 0 or v ~= -1 then
							local data = QuickChat.emoteIndexMap[v]
							if data then
								GetSelectedGroup().chatData[selectedEditEntry] = data.slashName
								RefreshSelectedChatEntryData()
								UpdateChatEntryDropDown()
							end
						end
					end,
					width = "full", 
				},
			},
		},
	}
	
	LAM:RegisterAddonPanel("QuickChat_ADDONMENU", panelData)
	LAM:RegisterOptionControls("QuickChat_ADDONMENU", optionsTable) 
end