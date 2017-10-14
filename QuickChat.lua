------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

ZO_CreateStringId("SI_BINDING_NAME_QUICK_CHAT", "Quick Chat") 
ZO_CreateStringId("SI_BINDING_NAME_QUICK_CHAT_GROUP", "Switch Chat Group") 
  
function QuickChat.OnChatMessage(eventCode, channelType, fromName, messageText, isCustomerService, fromDisplayName)

    if IsInGamepadPreferredMode() and QuickChat.acctSavedVariables.exitAfterSend then
	
		local postingPerson   = zo_strformat(SI_UNIT_NAME, fromName)
		local myPlayerName    = GetUnitName("player")
		local myPlayerNameRaw = GetRawUnitName("player")
		local myAccountName   = GetDisplayName()
		if fromName == myAccountName or postingPerson == myAccountName or fromName == myPlayerNameRaw or postingPerson == myPlayerName then
			--exit from the interface
			SCENE_MANAGER:ShowBaseScene()
		end
	end
end


local function ShowAnnoucement(text)
	local message = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.GAMEPAD_PAGE_NAVIGATION_FAILED)
	message:SetSound(SOUNDS.GAMEPAD_PAGE_NAVIGATION_FAILED)
	message:SetText(text)
	message:MarkSuppressIconFrame()
	message:MarkShowImmediately()
	CENTER_SCREEN_ANNOUNCE:QueueMessage(message)
end

function QuickChat.hookGamepadChatMenu()
	--fix gamepad chat menu tooltip
	--pchat warning!
	
	--remove camera animation 
	SCENE_MANAGER:GetScene("gamepadChatMenu"):RemoveFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
	
	--add quick chat keybindings
	local function prehookInitKeybinds(self) 
		local function runAfter() 
			local quickChatKeybindDescriptor = {
				{
					alignment = KEYBIND_STRIP_ALIGN_RIGHT,

					name = function()
						return "Group: " .. QuickChat.GetGroup(QuickChat.acctSavedVariables.currentGroupIndex).groupName
					end,

					keybind = "UI_SHORTCUT_LEFT_SHOULDER",
					
					handlesKeyUp = true,
					
					order = 19,

					callback = function(isUp)
						if not isUp then
							QuickChat:ShowGroupMenu()
						else
							QuickChat:HideMenu()
						end
					end, 
				},
				{
					alignment = KEYBIND_STRIP_ALIGN_RIGHT,

					name = "Quick Chat",

					keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
					
					handlesKeyUp = true,
					
					order = 10,
					
					callback = function(isUp)
						if not isUp then
							QuickChat:ShowChatMenu()
						else
							QuickChat:HideMenu()
						end
					end, 
				},
				{
					alignment = KEYBIND_STRIP_ALIGN_LEFT,
					
					name = function()
						if QuickChat.acctSavedVariables.exitAfterSend then
							return "Combat Mode"
						else
							return "Chat Mode"
						end
					end,
					 
					keybind = "UI_SHORTCUT_TERTIARY", 
					
					callback = function()
						QuickChat.acctSavedVariables.exitAfterSend = not QuickChat.acctSavedVariables.exitAfterSend
						if IsInGamepadPreferredMode() and SCENE_MANAGER:GetCurrentScene():GetName() == "gamepadChatMenu" then
							--Refresh keybind's text 
							CHAT_MENU_GAMEPAD.textInputAreaFocalArea:UpdateKeybinds()
						end
					end, 
				}
			}
			CHAT_MENU_GAMEPAD.textInputAreaFocalArea:AppendKeybind(quickChatKeybindDescriptor[1])
			CHAT_MENU_GAMEPAD.textInputAreaFocalArea:AppendKeybind(quickChatKeybindDescriptor[2])
			CHAT_MENU_GAMEPAD.textInputAreaFocalArea:AppendKeybind(quickChatKeybindDescriptor[3])
		end
		
		zo_callLater(runAfter, 0.5)
		--[[
        KEYBIND_STRIP:AddKeybindButton(self.quickslotKeybindStripDescriptor)
		table.insert(CHAT_MENU_GAMEPAD.textInputAreaKeybindDescriptor, quickChatKeybindDescriptor[1])
		table.insert(CHAT_MENU_GAMEPAD.textInputAreaKeybindDescriptor, quickChatKeybindDescriptor[2])
		CHAT_MENU_GAMEPAD.textInputAreaFocalArea:SetKeybindDescriptor(CHAT_MENU_GAMEPAD.textInputAreaKeybindDescriptor)
		]]
	end
	
	ZO_PreHook(ZO_ChatMenu_Gamepad, "InitializeFocusKeybinds", prehookInitKeybinds)
	
end

local function triggerAddonLoaded(eventCode, addonName)
  if  (addonName == QuickChat.name) then
    EVENT_MANAGER:UnregisterForEvent(QuickChat.name, EVENT_ADD_ON_LOADED);
    QuickChat.acctSavedVariables = ZO_SavedVars:NewAccountWide('QuickChatSavedVars', 1.0, nil, QuickChat.presets)
	QuickChat.AddonMenuInit()
	QuickChat.hookGamepadChatMenu()
  end
end
 
function QuickChat.ResetToDefaults()
	QuickChat.acctSavedVariables.currentGroupIndex = QuickChat.presets.currentGroupIndex
	QuickChat.acctSavedVariables.groups = QuickChat.presets.groups
	QuickChat.acctSavedVariables.groupsCount = QuickChat.presets.groupsCount
	QuickChat.acctSavedVariables.groupsData = QuickChat.presets.groupsData
end

function QuickChat:CreateGamepadRadialMenu()
    --self.gamepadMenu = ZO_RadialMenu:New(QuickChat_Gamepad, "ZO_RadialMenuHUDEntryTemplate_Gamepad", "DefaultRadialMenuAnimation", "DefaultRadialMenuEntryAnimation", "RadialMenu")
    self.gamepadMenu = ZO_RadialMenu:New(QuickChat_Gamepad, "ZO_GamepadPlayerEmoteRadialMenuEntryTemplate", "DefaultRadialMenuAnimation", "SelectableItemRadialMenuEntryAnimation", "RadialMenu")
    self.gamepadMenu:SetOnClearCallback(function() self:StopInteraction() end)
	
    local function SetupEntryControl(entryControl, data)
        entryControl.label:SetText(data.name)
        ZO_SetupSelectableItemRadialMenuEntryTemplate(entryControl)
    end

    self.gamepadMenu:SetCustomControlSetUpFunction(SetupEntryControl)
end 

function QuickChat:CreateKeyboardRadialMenu()
    self.keyboardMenu = ZO_RadialMenu:New(QuickChat_Keyboard, "ZO_PlayerToPlayerMenuEntryTemplate_Keyboard", "DefaultRadialMenuAnimation", "DefaultRadialMenuEntryAnimation", "RadialMenu")
    self.keyboardMenu:SetOnClearCallback(function() self:StopInteraction() end)
end

function QuickChat:GetRadialMenu()
    if IsInGamepadPreferredMode() then
        if not self.gamepadMenu then
            self:CreateGamepadRadialMenu()
        end
        return self.gamepadMenu
    else
        if not self.keyboardMenu then
            self:CreateKeyboardRadialMenu()
        end
        return self.keyboardMenu
    end
end



function QuickChat:AddMenuEntry(text, icons, enabled, selectedFunction)
    local normalIcon = enabled and icons.enabledNormal or icons.disabledNormal 
	if not enabled then
		selectedFunction = nil 
	end
	local data = { name = text }
    self:GetRadialMenu():AddEntry(text, normalIcon, normalIcon, selectedFunction, data)
end  


function QuickChat:StartInteraction(mode)
    --if not SCENE_MANAGER:IsInUIMode() then
        if not self.isInteracting then 
			local platformIcons = IsInGamepadPreferredMode() and QuickChat.GAMEPAD_MENU_ENTRIES or QuickChat.KEYBOARD_MENU_ENTRIES
			if mode == QuickChat.SELECT_GROUP_MODE then  
				for i = 1, QuickChat.acctSavedVariables.groupsCount do
					local index = QuickChat.GetGroupArrayIndex(i)
					local group = QuickChat.GetGroup(index)
					local function getCallback(groupIndex)
						return function()
							QuickChat.acctSavedVariables.currentGroupIndex = groupIndex 
							if IsInGamepadPreferredMode() and SCENE_MANAGER:GetCurrentScene():GetName() == "gamepadChatMenu"then
								--Refresh keybind's text 
								CHAT_MENU_GAMEPAD.textInputAreaFocalArea:UpdateKeybinds()
							end
						end
					end
					self:AddMenuEntry(group.groupName, platformIcons[QuickChat.ICON_TYPE_GROUP], true, getCallback(index))
				end
				self:AddMenuEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON), platformIcons[QuickChat.ICON_TYPE_CANCEL], true, nil )
			else  
				local group = QuickChat.GetGroup(QuickChat.acctSavedVariables.currentGroupIndex)
				for i = 1, group.chatEntriesCount do  
					local chatData = QuickChat.GetChatData(group, i)
					local emoteIndex = QuickChat.emoteSlashNameMap[chatData]
					if emoteIndex then
						--this is an emote
						local function getCallback(emoteIndex)
							return function()
								--play the emote
								PlayEmoteByIndex(emoteIndex)
							end
						end
						
						local emoteData = QuickChat.emoteIndexMap[emoteIndex]
						self:AddMenuEntry(zo_strformat("|cFFE690<<1>>|r", emoteData.displayName), platformIcons[emoteData.category], true, getCallback(emoteIndex))
					else
						local function getCallback(chatData)
							return function()
								if IsInGamepadPreferredMode() then
									--check init
									if not CHAT_MENU_GAMEPAD.chatEntryListKeybindDescriptor then
										--no init
										ShowAnnoucement("Please Open Chat Menu First:\nPress|t64:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_menu.dds|tMAIN MENU then |t48:48:/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds|t TEXT CHAT")
										return
									end
									--gamepad mode
									if SCENE_MANAGER:GetCurrentScene():GetName() ~= "gamepadChatMenu" then
										SCENE_MANAGER:Push("gamepadChatMenu")
									end
									  
									local textControl = CHAT_MENU_GAMEPAD.textInputControl:GetNamedChild("Text")
									local textEdit = textControl:GetNamedChild("EditBox")
									textEdit:SetText(chatData) 
								else
									--keyboard mode
								end
							end
						end
						
						self:AddMenuEntry(chatData, platformIcons[QuickChat.ICON_TYPE_CHAT], true, getCallback(chatData))
					end
					
					
				end
				self:AddMenuEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON), platformIcons[QuickChat.ICON_TYPE_CANCEL], true, nil )
			end
			
			 
			local menu = self:GetRadialMenu()
			menu:Show()
			
			LockCameraRotation(true)
			RETICLE:RequestHidden(true)
			self.isInteracting = true 
			
        end
    --end
end
 
function QuickChat:StopInteraction()     
    if self.isInteracting then
        self.isInteracting = false
        RETICLE:RequestHidden(false)
        LockCameraRotation(false)
        self:GetRadialMenu():SelectCurrentEntry()
        self:GetRadialMenu():Clear()
    end 
end

function QuickChat:ShowGroupMenu() 
	self:StartInteraction(QuickChat.SELECT_GROUP_MODE)
end

function QuickChat:ShowChatMenu()
	self:StartInteraction(QuickChat.SELECT_CHAT_MODE)
end

function QuickChat:HideMenu() 
	self:StopInteraction()
end
 
local function commandExec()
end
 
--== Slash command ==--
function QuickChat.cmd( text )
	if text == nil then text = true end
    LAM2:OpenToPanel(QuickChat_ADDONMENU) 
	local addons = LAM2.addonList:GetChild(1)
	if addons:GetNumChildren() ~= 0 then
		for a=1,addons:GetNumChildren(),1 do 
			if addons:GetChild(a):GetText() == QuickChat.settingName then
				addons:GetChild(a):SetSelected(true)
				break
			end	
		end
	end	
	--Second time's the charm
	if text then
		zo_callLater(function()QuickChat.cmd(false)end,500)
	end
end
SLASH_COMMANDS["/qc"] = QuickChat.cmd
EVENT_MANAGER:RegisterForEvent(QuickChat.name, EVENT_ADD_ON_LOADED, triggerAddonLoaded);   
EVENT_MANAGER:RegisterForEvent(QuickChat.name, EVENT_CHAT_MESSAGE_CHANNEL, QuickChat.OnChatMessage);  