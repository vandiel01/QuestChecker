local Revision = "11282020_124700"
----------------------------------------------------------------------------------------------------
                        --- AllTheThings Icon [Thanks to Crieve\Dylan] ---
                  --- AllTheThings Holiday Icon [Thanks to Dead Serious] ---
                        --- WOWHead Icon [Thanks to WOWHead] ---
        --- WOWHead Image can be found at:https://wow.zamimg.com/images/logos/big/new.png) ---
-------------------------------------------------------------------------------------------------------
local vQC_AppTitle = "|cffffff00"..strsub(GetAddOnMetadata("QuestChecker", "Title"),2).."|r v"..GetAddOnMetadata("QuestChecker", "Version")
------------------------------------------------------------------------
-- Globals (I Hope)
------------------------------------------------------------------------
-- Globals
	local QLog = _G["C_QuestLog"]
	local QLine = _G["C_QuestLine"]
	local QTask = _G["C_TaskQuest"]
	local CMap = _G["C_Map"]
-- Reuse Icons
	local ReuseIcons = {
		"|TInterface\\RAIDFRAME\\ReadyCheck-Ready:14|t",  --Did Done
		"|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:14|t",  --Not Done
		"|TInterface\\COMMON\\Indicator-Green:14|t",  -- Selected
		"|TInterface\\COMMON\\Indicator-Red:14|t", -- Not Selected
		"|TInterface\\HELPFRAME\\ReportLagIcon-Movement:20|t", -- In Progress
	}
-- Locals
	local CP, Re, TopRow, BotRow = 1, 0, 0, 0
	local mapID, StoryID, QC_Mem
-- Local Font Size
	local F_Title = 14		--Title Font Size
	local F_Header = 14		--Header Font Size
	local F_Sm_Title = 12	--Small Header Font Size
	local F_Body = 10		--Body/Normal Text Font Size
	
	-- Temp Number To Allow me to Change in future for "Resizing Window"
	local TmpHeight = 200	--Main Frame Height (One Influences All)
	local TmpWidth = 300	--Main Frame Width (One Influences All)
	local tHei = 7			--Gaps Between Title/Results
	local tRWi = 65			--Width of the Header (Temp)
	
	-- Temp Solution Until I make a SavedVariable for this
	local LeftRightATT = "RIGHT" --(use either LEFT or RIGHT) for position left or right of the Main Window
------------------------------------------------------------------------
-- Debugging Only
------------------------------------------------------------------------
-- local rQT = {11,33816,33815,34379,33468,32783,32989,37291,34563,34087,34685,34558,43341,43270}
-- local TestNbr = rQT[math.random(#rQT)]
-- local TestNbr = math.random(70000)
	local DEBUG = false
	local DebugOut = function(str)
		for _,name in pairs(CHAT_FRAMES) do
		   local frame = _G[name]
		   if frame.name == "DEBUGWindow" then
				frame:AddMessage(date("%H:%M.%S").." "..str)
		   end
		end
	end
------------------------------------------------------------------------
-- Table of Frame Backdrops
------------------------------------------------------------------------
	local Backdrop_A = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BlackMarket\\BlackMarketBackground-Tile",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local Backdrop_B = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BankFrame\\Bank-Background",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local ATTIconBkgnd = {
		bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	}
------------------------------------------------------------------------
-- Capturing ToolTips (Soon.. Need to Find Solution to Capturing Tooltips for Quick Search)
------------------------------------------------------------------------
--[[
function vQC_ToolTips(self)
	if DEBUG then DebugOut("vQC_ToolTips") end
	if IsAddOnLoaded("AllTheThings") and vQC_Main:IsVisible() and IsControlKeyDown() then
		local lines = self:NumLines()
		if lines ~= nil then
			for i = 1, lines do
				local txtL = getglobal(self:GetName() .. "TextLeft" .. i)
				if txtL:GetText() ~= nil then
					if txtL:GetText() == "Quest ID" then
						local txtR = getglobal(self:GetName() .. "TextRight" .. i)
						print("Found Quest ID# "..txtR:GetText())
					end
				end
			end
		end
	end
end
]]--
------------------------------------------------------------------------
-- Toggle Buttons To Prevent Multiple Query Loop
------------------------------------------------------------------------
function ToggleInputs(arg)
	if DEBUG then DebugOut("ToggleInputs") end
	if arg == 0 then
		vQC_QuestID:Disable()
		vQC_QID_Dec:Disable()
		vQC_QID_Inc:Disable()
		vQC_QuestID_Query:Disable()
		vQC_DebugIcon:Disable()
	end
	if arg == 1 then
		vQC_QuestID:Enable()
		vQC_QID_Dec:Enable()
		vQC_QID_Inc:Enable()
		vQC_QuestID_Query:Enable()
		vQC_DebugIcon:Enable()
	end
end
------------------------------------------------------------------------
-- Open/Close Main Window Before Doing Anything else
------------------------------------------------------------------------
function OpenQC(a)
	if DEBUG then DebugOut("OpenQC") end
	if vQC_Main:IsVisible() then
		vQC_Main:Hide()
	else
		if IsAddOnLoaded("AllTheThings") then  vQC_ATTMain:Show() else vQC_ATTMain:Hide() end
		vQC_Main:Show()
		-- Keep For Holiday Modification Later
		-- TopRow = math.random(0,5)*64
		-- vQC_ATTTitle.Icon:SetTexCoord(TopRow/512, (TopRow+64)/512, 0/64, 64/64)
	end
	CheckQuestAPI()
end
------------------------------------------------------------------------
-- Independent Query
------------------------------------------------------------------------
function CheckQuestAPI()
	if DEBUG then DebugOut("CheckQuestAPI") end
	vQC_NoResultsFound:Hide()
	vQC_YesResultsFound:Hide()
	vQC_StoryMain:Hide()	
	vQC_ATTIconBG:SetBackdropColor(math.random(), math.random(), math.random(), 1)
	if QLog.GetTitleForQuestID(vQC_QuestID:GetNumber()) == nil then
		vQC_Quest_Anim:Show()
		vQC_Quest_Anim.AG:Play()
		C_Timer.After(0, function()
			C_Timer.After(1, function()
				if QLog.GetTitleForQuestID(vQC_QuestID:GetNumber()) ~= nil then CheckQuestAPI() end
				vQC_Quest_Anim.AG:Stop()
				vQC_Quest_Anim:Hide()
			end)
		end)
	end
	QueryQuestAPI()
	vQC_QuestID:ClearFocus()
end
------------------------------------------------------------------------
-- Query for QuestLog ID/Title, Bliz too slow to call via API
------------------------------------------------------------------------
function QueryQuestAPI()
	if DEBUG then DebugOut("QueryQuestAPI") end
	if (QLog.GetTitleForQuestID(vQC_QuestID:GetNumber()) ~= nil) then
		if (QLog.IsOnQuest(vQC_QuestID:GetNumber())) then
			vQC_ResultHeader.Text:SetText(ReuseIcons[5].." |cffc8c864Quest In Progress|r")
		else
			if (QLog.IsQuestFlaggedCompleted(vQC_QuestID:GetNumber())) then
				vQC_ResultHeader.Text:SetText(ReuseIcons[1].." |cffc8c864Quest Completed|r")
			else
				vQC_ResultHeader.Text:SetText(ReuseIcons[2].." |cffc8c864Quest Not Completed|r")
			end
		end
		vQC_T_ID.Text:SetText(vQC_QuestID:GetNumber()) -- Quest ID
		vQC_T_Na.Text:SetText("|cffffff00|Hquest:"..vQC_QuestID:GetNumber()..":::::::::::::::|h"..QLog.GetTitleForQuestID(vQC_QuestID:GetNumber()).."|h|r") -- Quest Name
			vQC_T_Na:HookScript("OnEnter", function()
				GameTooltip:SetOwner(vQC_T_Na, "ANCHOR_CURSOR")
				GameTooltip:SetHyperlink("quest:"..vQC_QuestID:GetNumber()..":0:0:0:0:0:0:0")
				GameTooltip:Show()
			end)
			vQC_T_Na:HookScript("OnLeave", function() GameTooltip:Hide() end)
		vQCB_T_Lv.Text:SetText(QLog.GetQuestDifficultyLevel(vQC_QuestID:GetNumber())) -- Quest Level
		vQC_NoResultsFound:Hide()
		vQC_YesResultsFound:Show()
		Status = xpcall(GetQuestLineID(), err) -- Query GetQuestLineID
	else
		vQC_ResultHeader.Text:SetText("|cffc8c864Quest ID #|r"..vQC_QuestID:GetNumber().." |cffc8c864has...|r")
		vQC_NoResultsFound:Show()
		vQC_YesResultsFound:Hide()
	end
	-- Query AllTheThings SavedVariables
	Status = xpcall(ATTQueryVariables(), err)
	if vQC_WHLinkBox:IsVisible() and tonumber(string.sub(vQC_WHLinkTxt:GetText(),19)) ~= vQC_QuestID:GetNumber() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
	end
	vQC_QuestID:ClearFocus()
end
------------------------------------------------------------------------
-- Query from GetQuestZoneID, GetQuestLineInfo & GetMapInfo
------------------------------------------------------------------------
function GetQuestLineID()
	if DEBUG then DebugOut("GetQuestLineID") end
	vQC_Quest_Anim:Show()
	vQC_Quest_Anim.AG:Play()
	if Re == 0 then mapID = QTask.GetQuestZoneID(vQC_QuestID:GetNumber()) end
	-- Is this Quest in Storyline Chains? (and X,Y, Subzone, and Zone)
	mapID = QTask.GetQuestZoneID(vQC_QuestID:GetNumber())
	if mapID then
		StoryID = QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber()))
		if StoryID then
			-- Show Storyline Window
			vQC_StoryMain:Show()
			-- Make a Title for the Storyline Window
			vQC_StoryTitle.Text:SetText("|cffffff00"..StoryID.questLineName.."|r")
			-- Make an Text of Storyline
			vQC_T_St.Text:SetText("|cffffff00"..StoryID.questLineName.." |r")
			-- Mark an X,Y Coord
			vQC_T_XY.Text:SetText(mapID and string.format("%.1f",StoryID.x*100).." "..string.format("%.1f",StoryID.y*100) or "---")
			-- Show Subzone Name
			vQC_T_SZ.Text:SetText(mapID and CMap.GetMapInfo(QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).name or "---")
			-- Show Zone Name
			vQC_T_MZ.Text:SetText(mapID and CMap.GetMapInfo(CMap.GetMapInfo(QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).parentMapID).name or "---")
			-- Check/Pull Storyline if any
			Status = xpcall(ShowChainQuest(), err)
		else
			if Re < 5 then
				Re = Re + 1
				C_Timer.NewTimer(1, function() GetQuestLineID() end)
			else
				if Re == 5 then Re = 0 end
			end
		end
	else
		vQC_StoryMain:Hide()
		vQC_StoryTitle.Text:SetText("|cffffff00---|r")
		vQC_T_St.Text:SetText("---")
		vQC_T_XY.Text:SetText("---")
		vQC_T_SZ.Text:SetText("---")
		vQC_T_MZ.Text:SetText("---")
		vQC_SLText:SetText("")
	end
	if vQC_T_XY.Text:GetText() == "---" then vQC_MapPinIcon:Hide() else vQC_MapPinIcon:Show() end
	vQC_Quest_Anim.AG:Stop()
	vQC_Quest_Anim:Hide()
	Re = 0
end
------------------------------------------------------------------------
-- Query the Storyline (Need to Fix into Neater Column)
------------------------------------------------------------------------
function ShowChainQuest()
	if DEBUG then DebugOut("ShowChainQuest Start"..CP, vQC_ShowChainQuest_Timer) end
	if not vQC_StoryMain:IsVisible() then
		GetQuestLineID()
		return
	end
	local vQCSL, tSQC = {}, {}
	vQC_Story_Anim.AG:Play()
	vQC_Story_Anim:Show()
	ToggleInputs(0)
	wipe(vQCSL)
	wipe(tSQC)
	vQCSL = QLine.GetQuestLineQuests(QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).questLineID)
	for i = 1, #vQCSL do
		local tMsg = "".. --Temporay Shit To Fix into it's own frame for Retriving Data.. god knows what else
			(vQCSL[i] == vQC_QuestID:GetNumber() and (QLog.IsQuestFlaggedCompleted(vQCSL[i]) and ReuseIcons[3] or ReuseIcons[4]) or format("% 4d",i))..
			" "..
			(QLog.IsQuestFlaggedCompleted(vQCSL[i]) and ReuseIcons[1] or ReuseIcons[2])..
			" "..
			format("% 7d",vQCSL[i])..
			" "..
			(QLog.GetTitleForQuestID(vQCSL[i]) == nil and "|cffFF1100Querying Data...|r" or QLog.GetTitleForQuestID(vQCSL[i]))
			
		tinsert(tSQC,tMsg)
	end
	CP = CP + 1
	if type(tSQC) == "table" then tSQC = table.concat(tSQC,"\n") end
	vQC_SLText:SetText(tSQC)
	if strfind(vQC_SLText:GetText(),"Querying Data...") and CP < 6 then
		vQC_ShowChainQuest_Timer = C_Timer.NewTimer(2, ShowChainQuest)
		vQC_Story_Anim.Text:SetText("|cffc8c864"..CP.."|r")
		return
	else
		vQC_SLText:SetText(string.gsub(vQC_SLText:GetText(),"FF1100Querying Data...","DD1100Server Failed to Response..."))
	end
	ToggleInputs(1)
	CP = 0
	vQC_Story_Anim.AG:Stop()
	vQC_Story_Anim:Hide()
	if DEBUG then DebugOut("ShowChainQuest End"..CP, vQC_ShowChainQuest_Timer) end
end
------------------------------------------------------------------------
-- Query Information from AllTheThings SavedVariables
------------------------------------------------------------------------
function ATTQueryVariables()
	if DEBUG then DebugOut("ATTQueryVariables") end
	if IsAddOnLoaded("AllTheThings") then
		local MInfo, TeTab, tMInfo = {}, {}, {}
		local Found = 1
		wipe(MInfo)
		local questID,
			q,
			u = vQC_QuestID:GetNumber(),
			AllTheThings.GetDataMember("CollectedQuestsPerCharacter",{}),
			AllTheThings.GetDataMember("Characters",{})
		for a, b in pairs(q) do
		   if type(b) == "table" and b[questID] then
			  tinsert(MInfo,u[a])
		   end
		end
		wipe(TeTab) --Remove Duplicates
		for i = 1, #MInfo do
			z = string.sub(MInfo[i], 11, -3)
			for j = 1, #TeTab do
				y = string.sub(TeTab[j], 11, -3)
				if y == z then Found = 0 break else Found = 1 end
			end  
			if Found == 1 then tinsert(TeTab,MInfo[i]) end
		end
		MInfo = TeTab
		table.sort(MInfo, function(a,b) return a<b end) --In Future will add option to sort by
		wipe(tMInfo)
		if (#MInfo == 0) then
			MInfo = "No Data"
		elseif (type(MInfo) == "table") then
			for i = 1, #MInfo do
				if string.len(string.sub(MInfo[i], 11, -3)) >= 25 then MInfo[i] = MInfo[i]:sub(0,31).."..." end
				if UnitName("player").."-"..GetRealmName() == string.sub(MInfo[i], 11, -3) then
					tinsert(tMInfo,ReuseIcons[1]..MInfo[i])
				else
					tinsert(tMInfo,MInfo[i])
				end
			end
			MInfo = table.concat(tMInfo,"\n")
		end
		vQC_ATTArea:SetText(MInfo) --Main
	end
end
------------------------------------------------------------------------
-- Memory Check/Indicator and Dump if needed (Quest Query can be.... annoying)
------------------------------------------------------------------------
local function WatchMemoryCount()
	if DEBUG then DebugOut("WatchMemoryCount", QC_Mem) end
	C_Timer.After(30, WatchMemoryCount)
	QC_Mem = GetAddOnMemoryUsage("QuestChecker")
	if QC_Mem < 150 then vQC_Quest_MemIcon:Hide() else vQC_Quest_MemIcon:Show() end
	if QC_Mem > 1024 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Red") end
	if QC_Mem < 1024 and QC_Mem > 512 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Yellow") end
	if QC_Mem < 512 and QC_Mem > 151 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green") end
	if QC_Mem > 2048 and not InCombatLockdown() then
		print(strsub(GetAddOnMetadata("QuestChecker", "Title"),2).." (|cff00ff00Dumping Mem: "..(QC_Mem > 999 and format("%.1f%s", QC_Mem / 1024, " mb") or format("%.0f%s", QC_Mem, " kb")).."|r)")
		collectgarbage("collect")
		vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green")
	end
end
------------------------------------------------------------------------
-- Game ToolTip Simplified
------------------------------------------------------------------------
function ToolTipsOnly(f)
	if DEBUG then DebugOut("ToolTipsOnly", QC_Mem) end
	GameTooltip:Hide()
	GameTooltip:ClearLines()
	if f == 0 then return end
	GameTooltip:SetOwner(f, "ANCHOR_CURSOR")
	
	if f == vQC_MiniMap then msg = vQC_AppTitle end
	if f == vQC_MiniQ or f == vQC_MiniW then msg = "Quest ID\n\nClick here to check if other character has completed this quest." end
	if f == vQC_MapPinIcon then msg = "Click here to create an coords on Map" end
	if f == vQC_WHLinkIcon then msg = "Click on this to create a link of QuestID for WoWHead" end
	if f == vQC_Quest_MemIcon then msg = "Current: |cff00ff00"..(QC_Mem > 999 and format("%.1f%s", QC_Mem / 1024, " mb") or format("%.0f%s", QC_Mem, " kb")).."|r" end

	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end
------------------------------------------------------------------------
-- Increment/Decrement the Value
------------------------------------------------------------------------
function QuestUpDown(arg)
	if DEBUG then DebugOut("QuestUpDown") end
	local QNbr = vQC_QuestID:GetNumber()
	if arg == 1 then 
		QNbr = QNbr + 1
		if QNbr >= 70000 then QNbr = 0 end
	end
	if arg == 0 then
		QNbr = QNbr - 1
		if QNbr == -1 then QNbr = 70000 end
	end
	vQC_QuestID:SetNumber(QNbr)
	if vQC_WHLinkBox:IsVisible() and tonumber(string.sub(vQC_WHLinkTxt:GetText(),19)) ~= vQC_QuestID:GetNumber() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
	end
	CheckQuestAPI()
end
------------------------------------------------------------------------
-- WOWHead Link Display
------------------------------------------------------------------------
 local function WHLink()
 	if DEBUG then DebugOut("WHLink") end
	if vQC_WHLinkBox:IsVisible() and tonumber(string.sub(vQC_WHLinkTxt:GetText(),19)) ~= vQC_QuestID:GetNumber() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
		return
	end
	if vQC_WHLinkBox:IsVisible() then
		vQC_WHLinkBox:Hide()
	else
		vQC_WHLinkBox:Show()
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
	end
end
------------------------------------------------------------------------
-- Make an Map Pin or TomTom (if exist)
------------------------------------------------------------------------
local function MakePins()
	if DEBUG then DebugOut("MakePins") end
	if vQC_MapPinIcon:IsVisible() then
		if IsAddOnLoaded("TomTom") then
			TomTom:AddWaypoint(
				QTask.GetQuestZoneID(vQC_QuestID:GetNumber()),
				QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).x,
				QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).y,
				{ title = vQC_T_Na.Text:GetText(), persistent = nil, minimap = true, world = true, from = vQC_AppTitle, }
			)
		else
			CMap.SetUserWaypoint(
				UiMapPoint.CreateFromCoordinates(
					QTask.GetQuestZoneID(vQC_QuestID:GetNumber()),
					QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).x,
					QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).y
				)
			)
			C_SuperTrack.SetSuperTrackedUserWaypoint(true)
		end
	end
end
------------------------------------------------------------------------
-- Frequent Updates via Event Watcher 'QUEST_WATCH_LIST_CHANGED'
------------------------------------------------------------------------
function WatchQLogAct(event)
	if DEBUG then DebugOut("WatchQLogAct") end
	local questID = GetQuestID()
	if QuestMapFrame.DetailsFrame.questID ~= nil then questID = QuestMapFrame.DetailsFrame.questID end
	if questID == 0 then return end
	
	if event == 1 and not vQC_Main:IsVisible() then vQC_Main:Show() end
	
	if QuestFrame:IsVisible() then
		vQC_MiniQ:Show()
		vQC_MiniW:Hide()
		vQC_MiniQ.Text:SetText(questID)
	end
	if QuestMapFrame.DetailsFrame:IsVisible() then
		vQC_MiniQ:Hide()
		vQC_MiniW:Show()
		vQC_MiniW.Text:SetText(questID)
	end
	if vQC_Main:IsVisible() then
		vQC_QuestID:SetNumber(questID)
		CheckQuestAPI()
	end
end
------------------------------------------------------------------------
-- Mini Map Position when Dragging
------------------------------------------------------------------------
local myIconPos = 0
local function UpdateMiniMapButton()
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
    vQC_MiniMap:ClearAllPoints()
    vQC_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
end
------------------------------------------------------------------------
-- Nothing here, right?
------------------------------------------------------------------------
function DoNothing()
	if DEBUG then DebugOut("DoNothing") end
	--I mean, it's obvious isn't it?
end
------------------------------------------------------------------------
-- Mini Map Button
------------------------------------------------------------------------
	local vQC_MiniMap = CreateFrame("Button", "vQC_MiniMap", Minimap)
		vQC_MiniMap:SetFrameLevel(8)
		vQC_MiniMap:SetSize(28, 28)
		vQC_MiniMap:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
		vQC_MiniMap:ClearAllPoints()
		vQC_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -10, 0)
		vQC_MiniMap:SetMovable(true)
		vQC_MiniMap:RegisterForDrag("LeftButton")
			vQC_MiniMap:SetScript("OnClick", function() OpenQC() end)
			vQC_MiniMap:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniMap) end)
			vQC_MiniMap:SetScript("OnLeave", function() ToolTipsOnly(0) end)
			vQC_MiniMap:SetScript("OnDragStart", function()
				vQC_MiniMap:StartMoving()
				vQC_MiniMap:SetScript("OnUpdate", UpdateMiniMapButton)
			end)
			vQC_MiniMap:SetScript("OnDragStop", function()
				vQC_MiniMap:StopMovingOrSizing()
				vQC_MiniMap:SetScript("OnUpdate", nil)
				UpdateMiniMapButton()
			end)
------------------------------------------------------------------------
-- Mini Frame for Quest Log/World Frame
------------------------------------------------------------------------
	local vQC_MiniQ = CreateFrame("Frame", "vQC_MiniQ", QuestFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_MiniQ:SetBackdrop(Backdrop_A)
		vQC_MiniQ:SetSize(100,30)
		vQC_MiniQ:ClearAllPoints()
		vQC_MiniQ:SetPoint("TOPRIGHT", QuestFrame, -3, -23)
			vQC_MiniQ.Text = vQC_MiniQ:CreateFontString("T")
			vQC_MiniQ.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_MiniQ.Text:SetPoint("LEFT", vQC_MiniQ, 10, 0)
			vQC_MiniQ.Text:SetText("")
			local vQC_QFIcon = CreateFrame("Button", "vQC_QFIcon", vQC_MiniQ)
				vQC_QFIcon:SetSize(16,16)
				vQC_QFIcon:SetNormalTexture("Interface\\GossipFrame\\CampaignAvailableQuestIcon")
				vQC_QFIcon:SetPoint("RIGHT", vQC_MiniQ, -5, 0)
				vQC_QFIcon:SetScript("OnClick", function() WatchQLogAct(1) end)
				vQC_QFIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniQ) end)
				vQC_QFIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
	local vQC_MiniW = CreateFrame("Frame", "vQC_MiniW", QuestMapFrame.DetailsFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_MiniW:SetBackdrop(Backdrop_A)
		vQC_MiniW:SetSize(100,30)
		vQC_MiniW:ClearAllPoints()
		vQC_MiniW:SetPoint("TOPRIGHT", QuestMapFrame.DetailsFrame, 27, 45)
			vQC_MiniW.Text = vQC_MiniW:CreateFontString("T")
			vQC_MiniW.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_MiniW.Text:SetPoint("LEFT", vQC_MiniW, 10, 0)
			vQC_MiniW.Text:SetText("")
			local vQC_WFIcon = CreateFrame("Button", "vQC_WFIcon", vQC_MiniW)
				vQC_WFIcon:SetSize(16,16)
				vQC_WFIcon:SetNormalTexture("Interface\\GossipFrame\\CampaignAvailableQuestIcon")
				vQC_WFIcon:SetPoint("RIGHT", vQC_MiniW, -5, 0)
				vQC_WFIcon:SetScript("OnClick", function() WatchQLogAct(1) end)
				vQC_WFIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniW) end)
				vQC_WFIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
------------------------------------------------------------------------
-- Main Window
------------------------------------------------------------------------
-- Main Frame
	local vQC_Main = CreateFrame("Frame", "vQC_Main", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vQC_Main:SetBackdrop(Backdrop_A)
		vQC_Main:SetSize(TmpWidth,TmpHeight)
		vQC_Main:ClearAllPoints()
		vQC_Main:SetPoint("CENTER", UIParent)
		vQC_Main:EnableMouse(true)
		vQC_Main:SetMovable(true)
		vQC_Main:RegisterForDrag("LeftButton")
		vQC_Main:SetScript("OnDragStart", function() vQC_Main:StartMoving() end)
		vQC_Main:SetScript("OnDragStop", function() vQC_Main:StopMovingOrSizing() end)
		vQC_Main:SetClampedToScreen(true)
-- Main Title
	local vQC_Title = CreateFrame("Frame", "vQC_Title", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_Title:SetBackdrop(Backdrop_B)
		vQC_Title:SetSize(vQC_Main:GetWidth()-5,24)
		vQC_Title:ClearAllPoints()
		vQC_Title:SetPoint("TOP", vQC_Main, 0, -3)
			vQC_Title.IconA = vQC_Title:CreateTexture(nil, "ARTWORK")
			vQC_Title.IconA:SetSize(54,54)
			vQC_Title.IconA:SetPoint("TOPLEFT", vQC_Title, 5, 35)
			vQC_Title.IconA:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver")
			vQC_Title.IconB = vQC_Title:CreateTexture(nil, "ARTWORK")
			vQC_Title.IconB:SetSize(54,54)
			vQC_Title.IconB:SetPoint("TOPLEFT", vQC_Title, 25, 35)
			vQC_Title.IconB:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestComplete")
			vQC_Title.Text = vQC_Title:CreateFontString("T")
			vQC_Title.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Title, "OUTLINE")
			vQC_Title.Text:SetPoint("CENTER", vQC_Title)
			vQC_Title.Text:SetText(vQC_AppTitle)
			local vQC_TitleX = CreateFrame("Button", "vQC_TitleX", vQC_Title, "UIPanelCloseButton")
				vQC_TitleX:SetSize(26,26)
				vQC_TitleX:SetPoint("RIGHT", vQC_Title, 0, 0)
				vQC_TitleX:SetScript("OnClick", function() vQC_Main:Hide() end)
-- Main Quest Input
	local vQC_Quest = CreateFrame("Frame", "vQC_Quest", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		--vQC_Quest:SetBackdrop(Backdrop_B)
		vQC_Quest:SetSize(vQC_Main:GetWidth()-5,33)
		vQC_Quest:ClearAllPoints()
		vQC_Quest:SetPoint("TOP", vQC_Title, 0, 0-vQC_Title:GetHeight()+3)
		local vQC_Quest_MemIcon = CreateFrame("Button", "vQC_Quest_MemIcon", vQC_Quest)
			vQC_Quest_MemIcon:SetSize(16,16)
			vQC_Quest_MemIcon:SetPoint("TOPLEFT", vQC_Quest, 2, -1)
			vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green")
			vQC_Quest_MemIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_Quest_MemIcon) end)
			vQC_Quest_MemIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
			--vQC_Quest_MemIcon:Hide()
		local vQC_QuestID = CreateFrame("EditBox", "vQC_QuestID", vQC_Quest, "InputBoxTemplate")
			vQC_QuestID:SetPoint("CENTER", vQC_Quest, "CENTER", 0, 0)
			vQC_QuestID:SetSize(70,20)
			vQC_QuestID:SetMaxLetters(50)
			vQC_QuestID:SetAutoFocus(false)
			vQC_QuestID:SetMultiLine(false)
			vQC_QuestID:SetNumeric(true)
			vQC_QuestID:SetNumber(TestNbr or 0)
			vQC_QuestID:SetScript("OnEnterPressed", function() CheckQuestAPI() end)
		local vQC_QID_Dec = CreateFrame("Button", "vQC_QID_Dec", vQC_Quest)
			vQC_QID_Dec:SetSize(22,22)
			vQC_QID_Dec:SetPoint("LEFT", vQC_QuestID, -31, 0)
			vQC_QID_Dec:SetNormalTexture("Interface\\MINIMAP\\UI-Minimap-ZoomOutButton-Up")
			vQC_QID_Dec:SetScript("OnClick", function() QuestUpDown(0) end)
		local vQC_QID_Inc = CreateFrame("Button", "vQC_QID_Inc", vQC_Quest)
			vQC_QID_Inc:SetSize(22,22)
			vQC_QID_Inc:SetPoint("RIGHT", vQC_QuestID, 25, 0)
			vQC_QID_Inc:SetNormalTexture("Interface\\MINIMAP\\UI-Minimap-ZoomInButton-Up")
			vQC_QID_Inc:SetScript("OnClick", function() QuestUpDown(1) end)
		local vQC_QuestID_Query = CreateFrame("Button", "vQC_QuestID_Query", vQC_Quest)
			vQC_QuestID_Query:SetSize(24,24)
			vQC_QuestID_Query:SetPoint("RIGHT", vQC_QID_Inc, 25, 0)
			vQC_QuestID_Query:SetNormalTexture("Interface\\MINIMAP\\TRACKING\\None")
			vQC_QuestID_Query:SetScript("OnClick", function() CheckQuestAPI() end)
			
-- Main Quest Results Header (Progress, None, Done, Not Done)
	local vQC_ResultHeader = CreateFrame("Frame", "vQC_ResultHeader", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ResultHeader:SetSize(vQC_Main:GetWidth()-5,30)
		vQC_ResultHeader:ClearAllPoints()
		vQC_ResultHeader:SetPoint("TOP", vQC_Quest, 0, 0-vQC_Quest:GetHeight()+3)
			vQC_ResultHeader.Text = vQC_ResultHeader:CreateFontString("T")
			vQC_ResultHeader.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Header, "OUTLINE")
			vQC_ResultHeader.Text:SetPoint("CENTER", vQC_ResultHeader, "CENTER", 0, 0)
			vQC_ResultHeader.Text:SetText("")
-- Main Quest Results (Not Found)
	local vQC_NoResultsFound = CreateFrame("Frame", "vQC_NoResultsFound", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_NoResultsFound:SetSize(vQC_Main:GetWidth()-5,vQC_Main:GetHeight()-(vQC_Title:GetHeight()+vQC_ResultHeader:GetHeight()+vQC_Quest:GetHeight()-4))
		vQC_NoResultsFound:ClearAllPoints()
		vQC_NoResultsFound:SetPoint("TOP", vQC_ResultHeader, 0, 0-vQC_ResultHeader:GetHeight()+3)
			vQC_NoResultsFound.Text = vQC_NoResultsFound:CreateFontString("T")
			vQC_NoResultsFound.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_NoResultsFound.Text:SetPoint("TOP", vQC_NoResultsFound, 0, 0)
			vQC_NoResultsFound.Text:SetText(
				"|TInterface\\HELPFRAME\\HelpIcon-ReportAbuse:28|t|TInterface\\Store\\category-icon-placeholder:42|t"..
				"|TInterface\\PVPFrame\\PVPCurrency-Honor-Alliance:36|t|TInterface\\PVPFrame\\PVPCurrency-Honor-Horde:36|t"..
				"|TInterface\\HELPFRAME\\HelpIcon-CharacterStuck:32|t\n"..
				"Never Existed/Removed,\nRare/Hidden Trigger,\nOpposite Faction,\n|cff00ff00OR|r\nSlow API Request"
			)
-- Main Quest Results (Found)
	local vQC_YesResultsFound = CreateFrame("Frame", "vQC_YesResultsFound", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_YesResultsFound:SetSize(vQC_Main:GetWidth()-5,vQC_Main:GetHeight()-(vQC_Title:GetHeight()+vQC_ResultHeader:GetHeight()+vQC_Quest:GetHeight()-4))
		vQC_YesResultsFound:ClearAllPoints()
		vQC_YesResultsFound:SetPoint("TOP", vQC_ResultHeader, 0, 0-vQC_ResultHeader:GetHeight()+3)
			vQC_YesResultsFound.Text = vQC_YesResultsFound:CreateFontString("T") -- Quest Completed or Not
			vQC_YesResultsFound.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Header, "OUTLINE")
			vQC_YesResultsFound.Text:SetPoint("TOP", vQC_YesResultsFound, 0, -8)
			vQC_YesResultsFound.Text:SetText("")
			
-- Main Quest Results Layout
-- Quest ID
	local vQC_L_ID = CreateFrame("Frame", "vQC_L_ID", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_ID:SetSize(tRWi,20)
		vQC_L_ID:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*1)
			vQC_L_ID.Text = vQC_L_ID:CreateFontString("T")
			vQC_L_ID.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_ID.Text:SetPoint("RIGHT", vQC_L_ID)
			vQC_L_ID.Text:SetText("|cffffff00ID:|r")
	local vQC_T_ID = CreateFrame("Frame", "vQC_T_ID", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_ID:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_ID:GetWidth(),20)
		vQC_T_ID:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*1)
			vQC_T_ID.Text = vQC_T_ID:CreateFontString("T")
			vQC_T_ID.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_ID.Text:SetPoint("LEFT", vQC_T_ID)
			vQC_T_ID.Text:SetText("---")
-- Quest Name
	local vQC_L_Na = CreateFrame("Frame", "vQC_L_Na", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_Na:SetSize(tRWi,20)
		vQC_L_Na:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*3)
			vQC_L_Na.Text = vQC_L_Na:CreateFontString("T")
			vQC_L_Na.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_Na.Text:SetPoint("RIGHT", vQC_L_Na)
			vQC_L_Na.Text:SetText("|cffffff00Name:|r")
	local vQC_T_Na = CreateFrame("Frame", "vQC_T_Na", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_Na:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_Na:GetWidth(),20)
		vQC_T_Na:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*3)
			vQC_T_Na.Text = vQC_T_Na:CreateFontString("T")
			vQC_T_Na.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_Na.Text:SetPoint("LEFT", vQC_T_Na)
			vQC_T_Na.Text:SetText("---")
-- Quest Level
	local vQC_L_Lv = CreateFrame("Frame", "vQC_L_Lv", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_Lv:SetSize(tRWi,20)
		vQC_L_Lv:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*5)
			vQC_L_Lv.Text = vQC_L_Lv:CreateFontString("T")
			vQC_L_Lv.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_Lv.Text:SetPoint("RIGHT", vQC_L_Lv)
			vQC_L_Lv.Text:SetText("|cffffff00Level:|r")
	local vQCB_T_Lv = CreateFrame("Frame", "vQCB_T_Lv", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQCB_T_Lv:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_Lv:GetWidth(),20)
		vQCB_T_Lv:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*5)
			vQCB_T_Lv.Text = vQCB_T_Lv:CreateFontString("T")
			vQCB_T_Lv.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQCB_T_Lv.Text:SetPoint("LEFT", vQCB_T_Lv)
			vQCB_T_Lv.Text:SetText("---")
-- Quest XY Coord
	local vQC_L_XY = CreateFrame("Frame", "vQC_L_XY", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_XY:SetSize(tRWi,20)
		vQC_L_XY:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*7)
			vQC_L_XY.Text = vQC_L_XY:CreateFontString("T")
			vQC_L_XY.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_XY.Text:SetPoint("RIGHT", vQC_L_XY)
			vQC_L_XY.Text:SetText("|cffffff00Coord:|r")
	local vQC_T_XY = CreateFrame("Frame", "vQC_T_XY", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_XY:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_XY:GetWidth(),20)
		vQC_T_XY:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*7)
			vQC_T_XY.Text = vQC_T_XY:CreateFontString("T")
			vQC_T_XY.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_XY.Text:SetPoint("LEFT", vQC_T_XY)
			vQC_T_XY.Text:SetText("---")
-- Quest Subzone
	local vQC_L_SZ = CreateFrame("Frame", "vQC_L_SZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_SZ:SetSize(tRWi,20)
		vQC_L_SZ:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*9)
			vQC_L_SZ.Text = vQC_L_SZ:CreateFontString("T")
			vQC_L_SZ.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_SZ.Text:SetPoint("RIGHT", vQC_L_SZ)
			vQC_L_SZ.Text:SetText("|cffffff00Subzone:|r")
	local vQC_T_SZ = CreateFrame("Frame", "vQC_T_SZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_SZ:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_SZ:GetWidth(),20)
		vQC_T_SZ:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*9)
			vQC_T_SZ.Text = vQC_T_SZ:CreateFontString("T")
			vQC_T_SZ.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_SZ.Text:SetPoint("LEFT", vQC_T_SZ)
			vQC_T_SZ.Text:SetText("---")
-- Quest Zone
	local vQC_L_MZ = CreateFrame("Frame", "vQC_L_MZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_MZ:SetSize(tRWi,20)
		vQC_L_MZ:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*11)
			vQC_L_MZ.Text = vQC_L_MZ:CreateFontString("T")
			vQC_L_MZ.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_MZ.Text:SetPoint("RIGHT", vQC_L_MZ)
			vQC_L_MZ.Text:SetText("|cffffff00Zone:|r")
	local vQC_T_MZ = CreateFrame("Frame", "vQC_T_MZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_MZ:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_MZ:GetWidth(),20)
		vQC_T_MZ:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*11)
			vQC_T_MZ.Text = vQC_T_MZ:CreateFontString("T")
			vQC_T_MZ.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_MZ.Text:SetPoint("LEFT", vQC_T_MZ)
			vQC_T_MZ.Text:SetText("---")
-- Quest Storyline
	local vQC_L_St = CreateFrame("Frame", "vQC_L_St", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_St:SetSize(tRWi,20)
		vQC_L_St:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*13)
			vQC_L_St.Text = vQC_L_St:CreateFontString("T")
			vQC_L_St.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body, "OUTLINE")
			vQC_L_St.Text:SetPoint("RIGHT", vQC_L_St)
			vQC_L_St.Text:SetText("|cffffff00Storyline:|r")
	local vQC_T_St = CreateFrame("Frame", "vQC_T_St", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_St:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_St:GetWidth(),20)
		vQC_T_St:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*13)
			vQC_T_St.Text = vQC_T_St:CreateFontString("T")
			vQC_T_St.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
			vQC_T_St.Text:SetPoint("LEFT", vQC_T_St)
			vQC_T_St.Text:SetText("---")
------------------------------------------------------------------------
-- Storyline Window
------------------------------------------------------------------------
-- Storyline Main
	local vQC_StoryMain = CreateFrame("Frame", "vQC_StoryMain", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_StoryMain:SetBackdrop(Backdrop_A)
		vQC_StoryMain:SetSize(vQC_Main:GetWidth(),150)
		vQC_StoryMain:ClearAllPoints()
		vQC_StoryMain:SetPoint("BOTTOM", vQC_Main, 0, 0-vQC_StoryMain:GetHeight()+4)
		vQC_StoryMain:EnableMouse(true)
		vQC_StoryMain:SetMovable(true)
		vQC_StoryMain:RegisterForDrag("LeftButton")
		vQC_StoryMain:SetScript("OnDragStart", function() vQC_Main:StartMoving() end)
		vQC_StoryMain:SetScript("OnDragStop", function() vQC_Main:StopMovingOrSizing() end)
		vQC_StoryMain:Hide()
-- Storyline Title
	local vQC_StoryTitle = CreateFrame("Frame", "vQC_StoryTitle", vQC_StoryMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_StoryTitle:SetBackdrop(Backdrop_B)
		vQC_StoryTitle:SetSize(vQC_StoryMain:GetWidth()-5,24)
		vQC_StoryTitle:ClearAllPoints()
		vQC_StoryTitle:SetPoint("TOP", vQC_StoryMain, 0, -3)
			vQC_StoryTitle.Text = vQC_StoryTitle:CreateFontString("T")
			vQC_StoryTitle.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Title, "OUTLINE")
			vQC_StoryTitle.Text:SetPoint("CENTER", vQC_StoryTitle, "CENTER",0, 0)
			vQC_StoryTitle.Text:SetText("|cffffff00---|r")
-- Storyline Results
	local vQC_SLResult = CreateFrame("Frame", "vQC_SLResult", vQC_StoryMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_SLResult:SetSize(vQC_StoryMain:GetWidth()-5,vQC_StoryMain:GetHeight()-33)
		vQC_SLResult:ClearAllPoints()
		vQC_SLResult:SetPoint("TOP", vQC_StoryTitle, 0, 0-vQC_StoryTitle:GetHeight()+3)
			local vQC_SLScroll = CreateFrame("ScrollFrame", "vQC_SLScroll", vQC_SLResult, "UIPanelScrollFrameTemplate")
				vQC_SLScroll:SetSize(vQC_SLResult:GetWidth()-30,vQC_SLResult:GetHeight()-5)
				vQC_SLScroll:SetPoint("TOPLEFT", vQC_SLResult, 5, -5)
					vQC_SLText = CreateFrame("EditBox", "vQC_SLText", vQC_SLScroll)
					vQC_SLText:SetWidth(vQC_StoryMain:GetWidth()-25)
					vQC_SLText:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
					vQC_SLText:SetAutoFocus(false)
					vQC_SLText:SetMultiLine(true)
					vQC_SLText:EnableMouse(true)
					vQC_SLText:SetText("")
				vQC_SLScroll:SetScrollChild(vQC_SLText)
------------------------------------------------------------------------
-- ATT Window
------------------------------------------------------------------------
-- ATT Frame
	local vQC_ATTMain = CreateFrame("Frame", "vQC_ATTMain", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTMain:SetBackdrop(Backdrop_A)
		vQC_ATTMain:SetSize(150,TmpHeight)
		vQC_ATTMain:ClearAllPoints()
		if LeftRightATT == "LEFT" then
			vQC_ATTMain:SetPoint("TOPLEFT", vQC_Main, 0-vQC_ATTMain:GetWidth()+3, 0)
		elseif LeftRightATT == "RIGHT" then
			vQC_ATTMain:SetPoint("TOPRIGHT", vQC_Main, vQC_ATTMain:GetWidth()-2, 0)
		end
		vQC_ATTMain:EnableMouse(true)
		vQC_ATTMain:SetMovable(true)
		vQC_ATTMain:RegisterForDrag("LeftButton")
		vQC_ATTMain:SetScript("OnDragStart", function() vQC_Main:StartMoving() end)
		vQC_ATTMain:SetScript("OnDragStop", function() vQC_Main:StopMovingOrSizing() end)
-- ATT Title
	local vQC_ATTTitle = CreateFrame("Frame", "vQC_ATTTitle", vQC_ATTMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTTitle:SetBackdrop(Backdrop_B)
		vQC_ATTTitle:SetSize(vQC_ATTMain:GetWidth()-6,24)
		vQC_ATTTitle:ClearAllPoints()
		vQC_ATTTitle:SetPoint("TOP", vQC_ATTMain, 0, -3)
			vQC_ATTTitle.Text = vQC_ATTTitle:CreateFontString("T")
			vQC_ATTTitle.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_ATTTitle.Text:SetPoint("CENTER", vQC_ATTTitle, 0, 1)
			vQC_ATTTitle.Text:SetText("|cffffff00Completed By|r")
-- ATT Icon
	local vQC_ATTIconBG = CreateFrame("Frame", "vQC_ATTIconBG", vQC_ATTTitle, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTIconBG:SetBackdrop(ATTIconBkgnd)
		vQC_ATTIconBG:SetBackdropColor(math.random(), math.random(), math.random(), 1)
		vQC_ATTIconBG:SetSize(38,32)
		vQC_ATTIconBG:ClearAllPoints()
		if LeftRightATT == "LEFT" then
			vQC_ATTIconBG:SetPoint("TOPLEFT", vQC_ATTTitle, -16, 16)
		elseif LeftRightATT == "RIGHT" then
			vQC_ATTIconBG:SetPoint("TOPRIGHT", vQC_ATTTitle, 16, 16)
		end
			vQC_ATTTitle.Icon = vQC_ATTIconBG:CreateTexture(nil, "ARTWORK")
			vQC_ATTTitle.Icon:SetSize(42,42)
			vQC_ATTTitle.Icon:SetPoint("CENTER", vQC_ATTIconBG, "CENTER", 0, 2)
			vQC_ATTTitle.Icon:SetTexture("Interface\\Addons\\QuestChecker\\Images\\ATTImages")
			vQC_ATTTitle.Icon:SetTexCoord(0.625, 0, 0.625, 1, 0.75, 0, 0.75, 1)
			
-- ATT Result
	local vQC_ATTResult = CreateFrame("Frame", "vQC_ATTResult", vQC_ATTMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTResult:SetSize(vQC_ATTMain:GetWidth()-5,TmpHeight-vQC_ATTTitle:GetHeight()-3) --59 for Sort Area
		vQC_ATTResult:ClearAllPoints()
		vQC_ATTResult:SetPoint("TOP", vQC_ATTTitle, 0, 0-vQC_ATTTitle:GetHeight()+2)
		local vQC_ATTRScr = CreateFrame("ScrollFrame", "vQC_ATTRScr", vQC_ATTResult, "UIPanelScrollFrameTemplate")
			vQC_ATTRScr:SetPoint("TOPLEFT", vQC_ATTResult, 7, -7)
			vQC_ATTRScr:SetWidth(vQC_ATTResult:GetWidth()-35)
			vQC_ATTRScr:SetHeight(vQC_ATTResult:GetHeight()-12)
				vQC_ATTArea = CreateFrame("EditBox", "vQC_ATTArea", vQC_ATTRScr)
				vQC_ATTArea:SetWidth(vQC_ATTMain:GetWidth()-30)
				vQC_ATTArea:SetFont("Fonts\\FRIZQT__.TTF", F_Body)
				vQC_ATTArea:SetAutoFocus(false)
				vQC_ATTArea:SetMultiLine(true)
				vQC_ATTArea:EnableMouse(false)
			vQC_ATTRScr:SetScrollChild(vQC_ATTArea)
------------------------------------------------------------------------
-- Icon for Map Pin if X,Y Exist
------------------------------------------------------------------------
	local vQC_MapPinIcon = CreateFrame("Button", "vQC_MapPinIcon", vQC_T_XY)
		vQC_MapPinIcon:SetSize(24, 24)
		vQC_MapPinIcon:SetNormalTexture("Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked")
		vQC_MapPinIcon:ClearAllPoints()
		vQC_MapPinIcon:SetPoint("RIGHT", vQC_T_XY, -8, 0)
		vQC_MapPinIcon:SetScript("OnClick", function() MakePins() end)
		vQC_MapPinIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MapPinIcon) end)
		vQC_MapPinIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
		vQC_MapPinIcon:Hide()
------------------------------------------------------------------------
-- For WOWHead Icon/Link Frame
------------------------------------------------------------------------			
	-- Icon
	local vQC_WHLinkIcon = CreateFrame("Button", "vQC_WHLinkIcon", vQC_Quest)
		vQC_WHLinkIcon:SetSize(48,48)
		vQC_WHLinkIcon:SetNormalTexture("Interface\\Addons\\QuestChecker\\Images\\ATTImages")
		vQC_WHLinkIcon:GetNormalTexture():SetTexCoord(0.75, 0, 0.75, 1, 0.875, 0, 0.875, 1)
		vQC_WHLinkIcon:ClearAllPoints()
		vQC_WHLinkIcon:SetPoint("TOPLEFT", vQC_Quest, 5, -5)
		vQC_WHLinkIcon:SetScript("OnClick", function() WHLink() end)
		vQC_WHLinkIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_WHLinkIcon) end)
		vQC_WHLinkIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
	-- Show Link Box	
	local vQC_WHLinkBox = CreateFrame("Frame", "vQC_WHLinkBox", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_WHLinkBox:SetBackdrop(Backdrop_B)
		vQC_WHLinkBox:SetSize(220,33)
		vQC_WHLinkBox:SetPoint("TOPRIGHT", vQC_Main, 0, 31)
		local vQC_WHLinkTxt = CreateFrame("EditBox", "vQC_WHLinkTxt", vQC_WHLinkBox, "InputBoxTemplate")
			vQC_WHLinkTxt:SetSize(vQC_WHLinkBox:GetWidth()-20,19)
			vQC_WHLinkTxt:SetPoint("CENTER", vQC_WHLinkBox, "CENTER", 2, 0)
			vQC_WHLinkTxt:SetAutoFocus(false)
			vQC_WHLinkTxt:SetMultiLine(false)
			vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
		vQC_WHLinkBox:Hide()
------------------------------------------------------------------------
-- Search Animations
------------------------------------------------------------------------
	--For Query in Result Frame
	local vQC_Quest_Anim = CreateFrame("Frame", "vQC_Quest_Anim", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_Quest_Anim:SetBackdropColor(1,0,1,0)
		vQC_Quest_Anim:SetPoint("TOPRIGHT", vQC_Main, 3, -25)
		vQC_Quest_Anim:SetSize(58,58)
			vQC_Quest_Anim.Text = vQC_Quest_Anim:CreateFontString("T")
			vQC_Quest_Anim.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_Quest_Anim.Text:SetPoint("CENTER", vQC_Quest_Anim, "CENTER", 0, 0)
			vQC_Quest_Anim.Text:SetText("|cffc8c864API|r")
		vQC_Quest_Anim.Bkgnd = vQC_Quest_Anim:CreateTexture(nil, "ARTWORK")
		vQC_Quest_Anim.Bkgnd:SetTexture("Interface\\UNITPOWERBARALT\\Arcane_Circular_Frame")
		vQC_Quest_Anim.Bkgnd:SetAllPoints(vQC_Quest_Anim)
			vQC_Quest_Anim.AG = vQC_Quest_Anim.Bkgnd:CreateAnimationGroup()
				vQC_Quest_Anim.AG:SetLooping("REPEAT")
			vQC_Quest_Anim.CA = vQC_Quest_Anim.AG:CreateAnimation("Rotation")
				vQC_Quest_Anim.CA:SetDuration(5)
				vQC_Quest_Anim.CA:SetDegrees(360)
		vQC_Quest_Anim:Hide()
	--For Query in StoryLine
	local vQC_Story_Anim = CreateFrame("Frame", "vQC_Story_Anim", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_Story_Anim:SetBackdropColor(1,0,1,0)
		vQC_Story_Anim:SetPoint("BOTTOMRIGHT", vQC_Main, 3, 0)
		vQC_Story_Anim:SetSize(58,58)
			vQC_Story_Anim.Text = vQC_Story_Anim:CreateFontString("T")
			vQC_Story_Anim.Text:SetFont("Fonts\\FRIZQT__.TTF", F_Sm_Title, "OUTLINE")
			vQC_Story_Anim.Text:SetPoint("CENTER", vQC_Story_Anim, "CENTER", 1, 0)
			vQC_Story_Anim.Text:SetText("|cffc8c8640|r")
		vQC_Story_Anim.Bkgnd = vQC_Story_Anim:CreateTexture(nil, "ARTWORK")
		vQC_Story_Anim.Bkgnd:SetTexture("Interface\\UNITPOWERBARALT\\Ice_Circular_Frame")
		vQC_Story_Anim.Bkgnd:SetAllPoints(vQC_Story_Anim)
			vQC_Story_Anim.AG = vQC_Story_Anim.Bkgnd:CreateAnimationGroup()
				vQC_Story_Anim.AG:SetLooping("REPEAT")
			vQC_Story_Anim.CA = vQC_Story_Anim.AG:CreateAnimation("Rotation")
				vQC_Story_Anim.CA:SetDuration(5)
				vQC_Story_Anim.CA:SetDegrees(360)
		vQC_Story_Anim:Hide()
------------------------------------------------------------------------
-- Debug Quest # Randomonizer
------------------------------------------------------------------------
local vQC_DebugIcon = CreateFrame("Button", "vQC_DebugIcon", vQC_ATTTitle)
	vQC_DebugIcon:SetSize(24, 24)
	vQC_DebugIcon:SetNormalTexture("Interface\\GLUES\\CharacterSelect\\CharacterUndelete")
	vQC_DebugIcon:ClearAllPoints()
		if LeftRightATT == "LEFT" then
			vQC_DebugIcon:SetPoint("RIGHT", vQC_ATTTitle, 0, 0)
		elseif LeftRightATT == "RIGHT" then
			vQC_DebugIcon:SetPoint("LEFT", vQC_ATTTitle, 0, 0)
		end
	vQC_DebugIcon:SetScript("OnClick", function()
		vQC_QuestID:SetNumber(math.random(70000))
		CheckQuestAPI()
	end)
	-- vQC_DebugIcon:Hide()
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
local vQC_OnUpdate = CreateFrame("Frame")
vQC_OnUpdate:RegisterEvent("ADDON_LOADED")
vQC_OnUpdate:SetScript("OnEvent", function(self, event, ...)
-- More Test is needed on what events are needed but this is what i can tell so far is working as intended
	if event == "ADDON_LOADED" then
		local TheEvents = {
			"QUEST_DETAIL", --1 selecting fresh quest
			"QUEST_FINISHED", --3 when closing the quest/accept quest
			"QUEST_WATCH_LIST_CHANGED", --Minor when accept quest
			"QUEST_LOG_UPDATE", --opening questLog (cause QC to close)
			"QUEST_PROGRESS", --ready to turn in quest
			"QUEST_TURNED_IN", --update QC when quest turned in
			"QUEST_COMPLETE", --update QC when quest turned in
		}
		for ev = 1, #TheEvents do
			vQC_OnUpdate:RegisterEvent(TheEvents[ev])
		end
		vQC_OnUpdate:UnregisterEvent("ADDON_LOADED")
		vQC_OnUpdate:RegisterEvent("PLAYER_LOGIN")
	end
	if event == "PLAYER_LOGIN" then
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vQC_AppTitle)
		SLASH_QC1, SLASH_QC2 = '/qc', '/qchecker'
		SlashCmdList["QC"] = OpenQC
		vQC_Main:Hide()
		vQC_StoryMain:Hide()
		vQC_MiniQ:Hide()
		vQC_MiniW:Hide()
		WatchMemoryCount()
		vQC_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
	end
	
	if event == "QUEST_WATCH_LIST_CHANGED" and vQC_Main:IsVisible() then CheckQuestAPI() end
	-- print("Event Fired: "..event) --Debugging Purpose
	if (vQC_Main:IsVisible() or QuestFrame:IsVisible() or QuestMapFrame.DetailsFrame:IsVisible()) then WatchQLogAct(event) end
end)
--GameTooltip:HookScript("OnShow", vQC_ToolTips)
--GameTooltip:HookScript("OnTooltipSetQuest", vQC_ToolTips)