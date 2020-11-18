--Thanks to Crieve for ATT (AllTheThings) Icon (if you have ATT installed, it will appear)
local vQC_Title = "|cffffff00"..strsub(GetAddOnMetadata("QuestChecker", "Title"),2).."|r"
local vQC_Version = GetAddOnMetadata("QuestChecker", "Version")
local QLog = _G["C_QuestLog"]
local QLine = _G["C_QuestLine"]
local QTask = _G["C_TaskQuest"]
local CMap = _G["C_Map"]
local vQCHdr, vQCQue, vQCHT, vQCQT =  {}, {}, {}, {}
local QHeader = { "ID", "Name", "Level", "Objectives", "On_QuestQQ", "Have_ChainQQ", "Coord", "Zone", "Subzone", "DailyQQ", "World_QuestQQ", }
--local TestNbr = 43270 --Priest Legendary Chain from BSI
--"43341" --Uniting the Isle, popular BSI Starting Quest (Debugging Purpose)
local TmpHeight = 410

local vQC_Tooltips = function(arg, frame)
	GameTooltip:Hide()
	GameTooltip:ClearLines()
	if arg == 0 then return end
	if arg == 1 then
		if vQC_WHLinkF:IsVisible() then
			vQC_WHLinkF:Hide()
		else
			vQC_WHLinkF:Show()
			vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QTBox:GetNumber())
		end
		return
	end
	if arg == 2 then --create WP
		if vQC_QuestWP:IsVisible() then
			vQC_WHLinkF:Hide()
			if IsAddOnLoaded("TomTom") then
				TomTom:AddWaypoint(
					QTask.GetQuestZoneID(vQC_QTBox:GetNumber()),
					QLine.GetQuestLineInfo(vQC_QTBox:GetNumber(),QTask.GetQuestZoneID(vQC_QTBox:GetNumber())).x,
					QLine.GetQuestLineInfo(vQC_QTBox:GetNumber(),QTask.GetQuestZoneID(vQC_QTBox:GetNumber())).y,
					{
						title = vQCQT[2]:GetText(),
						persistent = nil,
						minimap = true,
						world = true,
						from = "Quest Checker",
					}
				)
			else
				CMap.SetUserWaypoint(
					UiMapPoint.CreateFromCoordinates(
						QTask.GetQuestZoneID(vQC_QTBox:GetNumber()),
						QLine.GetQuestLineInfo(vQC_QTBox:GetNumber(),QTask.GetQuestZoneID(vQC_QTBox:GetNumber())).x,
						QLine.GetQuestLineInfo(vQC_QTBox:GetNumber(),QTask.GetQuestZoneID(vQC_QTBox:GetNumber())).y
					)
				)
				C_SuperTrack.SetSuperTrackedUserWaypoint(true)
			end
		end
		return
	end
	GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
	if arg == "WPoint" then msg = "Click here to create an coords on Map" end
	if arg == "QChain" then msg = "This quest:\n|cffffff00"..QLog.GetTitleForQuestID(vQC_QTBox:GetNumber()).."|r\n(ID: "..vQC_QTBox:GetNumber()..") is chained." end
	if arg == "MiniMapButton" then msg = vQC_Title.." v"..vQC_Version end
	if arg == "QuestID" then msg = "Put in QuestID to check if you completed or not." end
	if arg == "QTBox" then msg = "Put in the Quest ID\n(Number Only)" end
	if arg == "CheckID" then msg = "Quest ID\n\nClick here to check if other character has completed this quest." end
	if arg == "WHLink" then msg = "Click on this to create a link of QuestID for WoWHead" end
	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end

local function OpenQuestID(a)
	vQC_MainFrame:ClearAllPoints()
	vQC_MainFrame:Show()
	vQC_QTBox:SetNumber(a)
	CheckQuestAPI()
end

function OpenQC()
	if vQC_MainFrame:IsVisible() then
		vQC_MainFrame:Hide()
	else
		vQC_MainFrame:ClearAllPoints()
		vQC_MainFrame:SetPoint("CENTER", UIParent)
		if IsAddOnLoaded("AllTheThings") then 
			vQC_MainFrame:SetHeight(TmpHeight)
		else
			vQC_ATTInfo:Hide()
			vQC_MainFrame:SetHeight(186)
			vQC_MainFrame.B:SetSize(vQC_MainFrame:GetWidth()-6,vQC_MainFrame:GetHeight()-6)
		end
		vQC_MainFrame:Show()
	end
	CheckQuestAPI()
end

function QuestInfo(event)
	local questID = GetQuestID()
	if QuestMapFrame.DetailsFrame.questID ~= nil then
		questID = QuestMapFrame.DetailsFrame.questID
	end
	if questID == 0 then return end
	if QuestFrame:IsVisible() then
		vQC_MiniQFrame:Show()
		vQC_MiniWFrame:Hide()
		vQC_MiniQFrame.N:SetText(questID)
	end
	if QuestMapFrame:IsVisible() then
		vQC_MiniQFrame:Hide()
		vQC_MiniWFrame:Show()
		vQC_MiniWFrame.N:SetText(questID)
	end
	if vQC_MainFrame:IsVisible() then
		vQC_QTBox:SetNumber(questID)
		CheckQuestAPI()
	end
end

function QuestUpDown(arg)
	local QNbr = vQC_QTBox:GetNumber() or 0
	if arg == 1 then 
		QNbr = QNbr + 1
		if QNbr >= 70000 then QNbr = 1 end
	end
	if arg == 0 then
		QNbr = QNbr - 1
		if QNbr <= 0 then QNbr = 70000 end
	end
	if arg == 0 or arg == 1 then vQC_QTBox:SetNumber(QNbr) end
	if vQC_WHLinkF:IsVisible() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QTBox:GetNumber())
	end
	CheckQuestAPI()
end

function CheckQuestAPI()
	local QNbrT = vQC_QTBox:GetNumber() or 0 --Get Number
	if QLog.GetTitleForQuestID(QNbrT) == nil then
		vQC_SearchLoad:Show()
		vQC_SearchLoad.AG:Play()
		C_Timer.After(0, function()
			C_Timer.After(1, function()
				for i = 1, 5, 1 do
					if QLog.GetTitleForQuestID(QNbrT) ~= nil then
						CheckQuestAPI()
						break
					end
				end
				vQC_SearchLoad.AG:Stop()
				vQC_SearchLoad:Hide()
			end)
		end)
	end
	CheckQuest()
	vQC_QTBox:ClearFocus()
end

function ShowChainQuest()
	local vQCSL, tSQC = {}, {}
	local DidDone = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:14|t"
	local NotDone = "|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:14|t"
	local DidLook = "|TInterface\\COMMON\\Indicator-Green:14|t"
	local NotLook = "|TInterface\\COMMON\\Indicator-Red:14|t"

	wipe(vQCSL)	
	vQCSL = QLine.GetQuestLineQuests(QLine.GetQuestLineInfo(vQC_QTBox:GetNumber(),QTask.GetQuestZoneID(vQC_QTBox:GetNumber())).questLineID)
	for i = 1, #vQCSL do
		if QLog.GetTitleForQuestID(vQCSL[i]) == nil then
			wipe(vQCSL)
			tSQC = "API too slow, please try again by pressing 'Check'"
			break
		end
		local tMsg = (vQCSL[i] == vQC_QTBox:GetNumber() and (QLog.IsQuestFlaggedCompleted(vQCSL[i]) and DidLook or NotLook) or format("%02d",i)).." "..
		(QLog.IsQuestFlaggedCompleted(vQCSL[i]) and DidDone or NotDone).." "..
		vQCSL[i]..": "..QLog.GetTitleForQuestID(vQCSL[i])
		
		tinsert(tSQC,tMsg)
	end
	if type(tSQC) == "table" then tSQC = table.concat(tSQC,"\n") end
	vQC_QCArea:SetText(tSQC)
end

function CheckQuest()
	local QNbr = vQC_QTBox:GetNumber() or 0
	
	if (QLog.GetTitleForQuestID(QNbr) ~= nil) then
		YesNo = QLog.IsQuestFlaggedCompleted(QNbr) and "Quest Completed" or "Quest Not Completed"
		for i = 1, #vQCHdr do
			vQCHdr[i]:Show()
			vQCQue[i]:Show()
		end
		
--62157 and 43270 Good Nil-able test reference
		local GQZID = QTask.GetQuestZoneID(QNbr)
		if (GQZID == 0 or GQZID == nil) then GQZID = false else GQZID = QTask.GetQuestZoneID(QNbr) end
		
		--Quest ID
		vQCQT[1]:SetText(QNbr)
		--Quest Name
		vQCQT[2]:SetText(QLog.GetTitleForQuestID(QNbr))
		--Quest Level
		vQCQT[3]:SetText(QLog.GetQuestDifficultyLevel(QNbr))
		--Quest Objectives
		vQCQT[4]:SetText("|cffffff00|Hquest:"..QNbr..":::::::::::::::|h["..vQCQT[2]:GetText().."]|h|r") --Obj
			vQC_Query4:HookScript("OnEnter", function()
				GameTooltip:SetOwner(vQC_Query4, "ANCHOR_CURSOR")
				GameTooltip:SetHyperlink("quest:"..QNbr..":0:0:0:0:0:0:0")
				GameTooltip:Show()
			end)
			vQC_Query4:HookScript("OnLeave", function() GameTooltip:Hide() end)
		--Currently On Quest?
		vQCQT[5]:SetText(QLog.IsOnQuest(QNbr) and "Yes" or "No")
		--Is this Quest in any type of Storyline/Quest Chains?
		vQCQT[6]:SetText(GQZID and "Yes |cffffff00["..QLine.GetQuestLineInfo(QNbr,QTask.GetQuestZoneID(QNbr)).questLineName.."]|r" or "No")
			if vQCQT[6]:GetText() == "No" then
				vQC_QChains:Hide()
				vQC_QuestChain:Hide()
			else
				vQC_QChains:Show()
				vQC_QuestChain:Show()
				vQC_QChains.T:SetText(GQZID and "|cffffff00"..QLine.GetQuestLineInfo(QNbr,QTask.GetQuestZoneID(QNbr)).questLineName.."|r" or "--")
				ShowChainQuest()
			end
		--Quest Coord, Subzone and Zone
		vQCQT[7]:SetText(GQZID and string.format("%.2f",QLine.GetQuestLineInfo(QNbr,QTask.GetQuestZoneID(QNbr)).x*100).." "..string.format("%.2f",QLine.GetQuestLineInfo(QNbr,QTask.GetQuestZoneID(QNbr)).y*100) or "--") -- X,Y Coord
			if vQCQT[7]:GetText() == "--" then vQC_QuestWP:Hide() else vQC_QuestWP:Show() end
		vQCQT[8]:SetText(GQZID and CMap.GetMapInfo(QTask.GetQuestZoneID(QNbr)).name or "--") --This Zone
		vQCQT[9]:SetText(GQZID and CMap.GetMapInfo(CMap.GetMapInfo(QTask.GetQuestZoneID(QNbr)).parentMapID).name or "--") --Parent Zone
		
		--Is Quest Repeatable?
		vQCQT[10]:SetText(QLog.IsRepeatableQuest(QNbr) and "Yes" or "No")
		--Is Quest Daily?
		vQCQT[11]:SetText(QLog.IsWorldQuest(QNbr) and "Yes" or "No")
	else
		for i = 1, #vQCHdr do
			vQCHdr[i]:Hide()
			vQCQue[i]:Hide()
		end
		vQC_QChains:Hide()
		YesNo = "\n Quest ID #|cffffff00"..QNbr.."|r"..
		"\n\n |TInterface\\HELPFRAME\\HelpIcon-ReportAbuse:26|t Never existed/removed, |TInterface\\HELPFRAME\\HelpIcon-ReportAbuse:26|t"..
		"\n |TInterface\\Store\\category-icon-placeholder:40|t Rare/Hidden Trigger, |TInterface\\Store\\category-icon-placeholder:40|t"..
		"\n |TInterface\\PVPFrame\\PVPCurrency-Honor-Alliance:36|t Opposite faction, |TInterface\\PVPFrame\\PVPCurrency-Honor-Horde:36|t"..
		"\n |cff00ff00OR|r"..
		"\n |TInterface\\HELPFRAME\\HelpIcon-CharacterStuck:32|t Slow API Request |TInterface\\HELPFRAME\\HelpIcon-CharacterStuck:32|t"
	end
	vQC_ResultFrame.YesNo:SetText(YesNo)

	if IsAddOnLoaded("AllTheThings") then
		local MInfo, TeTab, tMInfo = {}, {}, {}
		local Found = 1
		wipe(MInfo)
		local questID,
			q,
			u = QNbr,
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
			local CName = UnitName("player").."-"..GetRealmName()
			for i = 1, #MInfo do
				z = string.sub(MInfo[i], 11, -3)				
				if CName == z then
					tinsert(tMInfo,"|TInterface\\COMMON\\Indicator-Green:16|t"..MInfo[i])
				else
					tinsert(tMInfo,MInfo[i])
				end
			end
			MInfo = table.concat(tMInfo,"\n")
		end
		vQC_ATTArea:SetText(MInfo) --Main
	end
end

local myIconPos = 0
local function UpdateMiniMapButton()
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
    vQC_MiniMapButton:ClearAllPoints()
    vQC_MiniMapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
end
function FixString(Str)
	LongStr = strlen(Str)
	FindPat = { "_", "QQ" }
	ReplPat = { " ", "?" }
	for i = 1, LongStr do
		for i = 1, #FindPat do
			if gmatch(Str, FindPat[i]) then
				Str = gsub(Str,FindPat[i],ReplPat[i])
			end
		end
	end
	return "|cffffff00"..Str..":|r"
end

------------------------------------------------------------------------
-- Build Frame - Quest Checker Main/Mini
------------------------------------------------------------------------
local DefaultBackdrop = {
	edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
--MiniMap Button
local vQC_MiniMapButton = CreateFrame("Button", "vQC_MiniMapButton", Minimap)
	vQC_MiniMapButton:SetFrameLevel(8)
	vQC_MiniMapButton:SetSize(28, 28)
	vQC_MiniMapButton:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
    vQC_MiniMapButton:ClearAllPoints()
    vQC_MiniMapButton:SetPoint("BOTTOM", Minimap, "LEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
	vQC_MiniMapButton:SetMovable(true)
	vQC_MiniMapButton:RegisterForDrag("LeftButton")
		vQC_MiniMapButton:SetScript("OnClick", function() OpenQC() end)
		vQC_MiniMapButton:SetScript("OnEnter", function() vQC_Tooltips("MiniMapButton",vQC_MiniMapButton) end)
		vQC_MiniMapButton:SetScript("OnLeave", function() vQC_Tooltips(0) end)
		vQC_MiniMapButton:SetScript("OnDragStart", function()
			vQC_MiniMapButton:StartMoving()
			vQC_MiniMapButton:SetScript("OnUpdate", UpdateMiniMapButton)
		end)
		vQC_MiniMapButton:SetScript("OnDragStop", function()
			vQC_MiniMapButton:StopMovingOrSizing()
			vQC_MiniMapButton:SetScript("OnUpdate", nil)
			UpdateMiniMapButton()
		end)
		
--Mini Frame for Quest Logs
local vQC_MiniQFrame = CreateFrame("Frame", "vQC_MiniQFrame", QuestFrame, BackdropTemplateMixin and "BackdropTemplate")
	vQC_MiniQFrame:SetBackdrop(DefaultBackdrop)
	vQC_MiniQFrame:SetSize(100,30)
	vQC_MiniQFrame:ClearAllPoints()
	vQC_MiniQFrame:SetPoint("TOPRIGHT", QuestFrame, -3, -23)
		vQC_MiniQFrame.B = vQC_MiniQFrame:CreateTexture(nil, "BACKGROUND")
		vQC_MiniQFrame.B:SetSize(vQC_MiniQFrame:GetWidth()-6,vQC_MiniQFrame:GetHeight()-6)
		vQC_MiniQFrame.B:SetPoint("TOPLEFT", vQC_MiniQFrame, 3, -3)
		vQC_MiniQFrame.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Maw")
		vQC_MiniQFrame.N = vQC_MiniQFrame:CreateFontString("N")
		vQC_MiniQFrame.N:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_MiniQFrame.N:SetPoint("LEFT", vQC_MiniQFrame, 10, 0)
		vQC_MiniQFrame.N:SetText()
		local vQC_QFIcon = CreateFrame("Button", "vQC_QFIcon", vQC_MiniQFrame)
			vQC_QFIcon:SetSize(16,16)
			vQC_QFIcon:SetNormalTexture("Interface\\GossipFrame\\CampaignAvailableQuestIcon")
			vQC_QFIcon:SetPoint("RIGHT", vQC_MiniQFrame, -5, 0)
			vQC_QFIcon:SetScript("OnClick", function() OpenQuestID(vQC_MiniQFrame.N:GetText()) end)
			vQC_QFIcon:SetScript("OnEnter", function() vQC_Tooltips("CheckID",vQC_MiniQFrame.N) end)
			vQC_QFIcon:SetScript("OnLeave", function() vQC_Tooltips(0) end)
local vQC_MiniWFrame = CreateFrame("Frame", "vQC_MiniWFrame", QuestMapFrame.DetailsFrame, BackdropTemplateMixin and "BackdropTemplate")
	vQC_MiniWFrame:SetBackdrop(DefaultBackdrop)
	vQC_MiniWFrame:SetSize(100,30)
	vQC_MiniWFrame:ClearAllPoints()
	vQC_MiniWFrame:SetPoint("TOPRIGHT", QuestMapFrame.DetailsFrame, 27, 45)
		vQC_MiniWFrame.B = vQC_MiniWFrame:CreateTexture(nil, "BACKGROUND")
		vQC_MiniWFrame.B:SetSize(vQC_MiniWFrame:GetWidth()-6,vQC_MiniWFrame:GetHeight()-6)
		vQC_MiniWFrame.B:SetPoint("TOPLEFT", vQC_MiniWFrame, 3, -3)
		vQC_MiniWFrame.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Maw")
		vQC_MiniWFrame.N = vQC_MiniWFrame:CreateFontString("N")
		vQC_MiniWFrame.N:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_MiniWFrame.N:SetPoint("LEFT", vQC_MiniWFrame, 10, 0)
		vQC_MiniWFrame.N:SetText()
		local vQC_WFIcon = CreateFrame("Button", "vQC_WFIcon", vQC_MiniWFrame)
			vQC_WFIcon:SetSize(16,16)
			vQC_WFIcon:SetNormalTexture("Interface\\GossipFrame\\CampaignAvailableQuestIcon")
			vQC_WFIcon:SetPoint("RIGHT", vQC_MiniWFrame, -5, 0)
			vQC_WFIcon:SetScript("OnClick", function() OpenQuestID(vQC_MiniWFrame.N:GetText()) end)
			vQC_WFIcon:SetScript("OnEnter", function() vQC_Tooltips("CheckID",vQC_MiniWFrame.N) end)
			vQC_WFIcon:SetScript("OnLeave", function() vQC_Tooltips(0) end)

--Main Frame
local vQC_MainFrame = CreateFrame("Frame", "vQC_MainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	vQC_MainFrame:SetBackdrop(DefaultBackdrop)
	vQC_MainFrame:SetSize(350,TmpHeight)
	vQC_MainFrame:ClearAllPoints()
	vQC_MainFrame:SetPoint("CENTER", UIParent)
	vQC_MainFrame:EnableMouse(true)
	vQC_MainFrame:SetMovable(true)
	vQC_MainFrame:RegisterForDrag("LeftButton")
	vQC_MainFrame:SetScript("OnDragStart", function() vQC_MainFrame:StartMoving() end)
	vQC_MainFrame:SetScript("OnDragStop", function() vQC_MainFrame:StopMovingOrSizing() end)
	vQC_MainFrame:SetClampedToScreen(true)
		vQC_MainFrame.B = vQC_MainFrame:CreateTexture(nil, "BACKGROUND")
		vQC_MainFrame.B:SetSize(vQC_MainFrame:GetWidth()-6,vQC_MainFrame:GetHeight()-6)
		vQC_MainFrame.B:SetPoint("TOPLEFT", vQC_MainFrame, 3, -3)
		vQC_MainFrame.B:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment")

	--Title Frame
	local vQC_TitleFrame = CreateFrame("Frame", "vQC_TitleFrame", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_TitleFrame:SetBackdrop(DefaultBackdrop)
		vQC_TitleFrame:SetSize(vQC_MainFrame:GetWidth()-5,30)
		vQC_TitleFrame:ClearAllPoints()
		vQC_TitleFrame:SetPoint("TOP", vQC_MainFrame, 0, -3)
			vQC_TitleFrame.B = vQC_TitleFrame:CreateTexture(nil, "BACKGROUND")
			vQC_TitleFrame.B:SetSize(vQC_TitleFrame:GetWidth()-10,vQC_TitleFrame:GetHeight()-4)
			vQC_TitleFrame.B:SetPoint("TOP", vQC_TitleFrame, 0, 0)
			vQC_TitleFrame.B:SetTexture("Interface\\BankFrame\\Bank-Background")
			vQC_TitleFrame.Ia = vQC_TitleFrame:CreateTexture(nil, "ARTWORK")
			vQC_TitleFrame.Ia:SetSize(64,64)
			vQC_TitleFrame.Ia:SetPoint("TOPLEFT", vQC_TitleFrame, 5, 35)
			vQC_TitleFrame.Ia:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver")
			vQC_TitleFrame.Ib = vQC_TitleFrame:CreateTexture(nil, "ARTWORK")
			vQC_TitleFrame.Ib:SetSize(64,64)
			vQC_TitleFrame.Ib:SetPoint("TOPLEFT", vQC_TitleFrame, 25, 35)
			vQC_TitleFrame.Ib:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestComplete")
			vQC_TitleFrame.T = vQC_TitleFrame:CreateFontString("T")
			vQC_TitleFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
			vQC_TitleFrame.T:SetPoint("CENTER", vQC_TitleFrame)
			vQC_TitleFrame.T:SetText(vQC_Title)
			local vQC_TitleFrameX = CreateFrame("Button", "vQC_TitleFrameX", vQC_TitleFrame, "UIPanelCloseButton")
				vQC_TitleFrameX:SetSize(32,32)
				vQC_TitleFrameX:SetPoint("RIGHT", vQC_TitleFrame, 0, 0)
				vQC_TitleFrameX:SetScript("OnClick", function() vQC_MainFrame:Hide() end)

	--Quest ID Input
	local vQC_QuestFrame = CreateFrame("Frame", "vQC_QuestFrame", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_QuestFrame:SetBackdrop(DefaultBackdrop)
		vQC_QuestFrame:SetSize(vQC_MainFrame:GetWidth()-5,32)
		vQC_QuestFrame:ClearAllPoints()
		vQC_QuestFrame:SetPoint("TOP", vQC_TitleFrame, 0, 0-vQC_TitleFrame:GetHeight()+3)
		local vQC_QTBox = CreateFrame("EditBox", "vQC_QTBox", vQC_QuestFrame, "InputBoxTemplate")
			vQC_QTBox:SetPoint("CENTER", vQC_QuestFrame, "CENTER", 0, 0)
			vQC_QTBox:SetSize(70,20)
			vQC_QTBox:SetMaxLetters(50)
			vQC_QTBox:SetAutoFocus(false)
			vQC_QTBox:SetMultiLine(false)
			vQC_QTBox:SetNumeric(true)
			vQC_QTBox:SetNumber(TestNbr or 0)
			vQC_QTBox:SetScript("OnEnter", function() vQC_Tooltips("QTBox",vQC_QTBox) end)
			vQC_QTBox:SetScript("OnLeave", function() vQC_Tooltips(0) end)
			vQC_QTBox:SetScript("OnEnterPressed", function() CheckQuestAPI() end)
		local vQC_QTBoxT = vQC_QuestFrame:CreateFontString("vQC_QTBoxT")
			vQC_QTBoxT:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
			vQC_QTBoxT:SetPoint("LEFT", vQC_QuestFrame, 8, 0)
			vQC_QTBoxT:SetText("Quest ID")
		local vQC_QTND = CreateFrame("Button", "vQC_QTND", vQC_QuestFrame, "UIPanelButtonTemplate")
			vQC_QTND:SetSize(16,16)
			vQC_QTND:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up")
			vQC_QTND:SetPoint("LEFT", vQC_QTBox, -25, 1)
			vQC_QTND:SetScript("OnClick", function() QuestUpDown(0) end)
		local vQC_QTNU = CreateFrame("Button", "vQC_QTNU", vQC_QuestFrame, "UIPanelButtonTemplate")
			vQC_QTNU:SetSize(16,16)
			vQC_QTNU:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up")
			vQC_QTNU:SetPoint("RIGHT", vQC_QTBox, 20, 1)
			vQC_QTNU:SetScript("OnClick", function() QuestUpDown(1) end)
		local vQC_QTBoxB = CreateFrame("Button", "vQC_QTBoxB", vQC_QuestFrame, "UIPanelButtonTemplate")
			vQC_QTBoxB:SetSize(60,20)
			vQC_QTBoxB:SetPoint("RIGHT", vQC_QuestFrame, -5, 1)
			vQC_QTBoxB:SetText("Check")
			vQC_QTBoxB:SetScript("OnClick", function() CheckQuestAPI() end)

	--Quest ID Result Frame
	local vQC_ResultFrame = CreateFrame("Frame", "vQC_ResultFrame", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ResultFrame:SetBackdrop(DefaultBackdrop)
		vQC_ResultFrame:SetSize(vQC_MainFrame:GetWidth()-5,225)
		vQC_ResultFrame:ClearAllPoints()
		vQC_ResultFrame:SetPoint("TOP", vQC_QuestFrame, 0, 0-vQC_QuestFrame:GetHeight()+2)
			vQC_ResultFrame.B = vQC_ResultFrame:CreateTexture(nil, "BACKGROUND")
			vQC_ResultFrame.B:SetSize(vQC_ResultFrame:GetWidth()-10,vQC_ResultFrame:GetHeight()-10)
			vQC_ResultFrame.B:SetPoint("CENTER", vQC_ResultFrame, 0, 0)
			vQC_ResultFrame.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Azerite")
			vQC_ResultFrame.YesNo = vQC_ResultFrame:CreateFontString("T") -- Quest Completed or Not
			vQC_ResultFrame.YesNo:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vQC_ResultFrame.YesNo:SetPoint("TOP", vQC_ResultFrame, 0, -8)
			vQC_ResultFrame.YesNo:SetText()

			local QHdrPos = -26
			for i = 1, #QHeader do
				local F1 = CreateFrame("Frame", "vQC_Header"..i, vQC_ResultFrame, BackdropTemplateMixin and "BackdropTemplate")
					F1:SetSize(105,20)
					F1:SetPoint("TOPLEFT", vQC_ResultFrame, 0, QHdrPos)
				vQCHdr[i] = F1
				local HHdr = F1:CreateFontString(nil, "OVERLAY")
						HHdr:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
						HHdr:SetPoint("RIGHT", "vQC_Header"..i)
						HHdr:SetText(FixString(QHeader[i]))
				vQCHT[i] = HHdr
				
				local F2 = CreateFrame("Frame", "vQC_Query"..i, vQC_ResultFrame, BackdropTemplateMixin and "BackdropTemplate")
					F2:SetSize(vQC_ResultFrame:GetWidth()-F1:GetWidth(),20)
					F2:SetPoint("TOPRIGHT", vQC_ResultFrame, 0, QHdrPos-1)
				vQCQue[i] = F2
				local QHdr = F2:CreateFontString(nil, "OVERLAY")
						QHdr:SetFont("Fonts\\FRIZQT__.TTF", 11)
						QHdr:SetPoint("LEFT", "vQC_Query"..i)
						QHdr:SetText("")
				vQCQT[i] = QHdr
				
				QHdrPos = QHdrPos - 17
			end
			
	--Display Result on Quest ID Pulled From ATT Database
	local vQC_ATTInfo = CreateFrame("Frame", "vQC_ATTInfo", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTInfo:SetBackdrop(DefaultBackdrop)
		vQC_ATTInfo:SetWidth(vQC_MainFrame:GetWidth()-5)
		vQC_ATTInfo:SetHeight(floor(vQC_MainFrame:GetHeight())-(floor(vQC_TitleFrame:GetHeight())+floor(vQC_QuestFrame:GetHeight())+floor(vQC_ResultFrame:GetHeight()))+1)
		vQC_ATTInfo:ClearAllPoints()
		vQC_ATTInfo:SetPoint("TOP", vQC_ResultFrame, 0, 0-vQC_ResultFrame:GetHeight()+3)
			vQC_ATTInfo.B = vQC_ATTInfo:CreateTexture(nil, "BACKGROUND")
			vQC_ATTInfo.B:SetSize(vQC_ATTInfo:GetWidth()-10,vQC_ATTInfo:GetHeight()-10)
			vQC_ATTInfo.B:SetPoint("CENTER", vQC_ATTInfo, 0, 0)
			vQC_ATTInfo.B:SetTexture("Interface\\Tooltips\\CHATBUBBLE-BACKGROUND")
			vQC_ATTInfo.T = vQC_ATTInfo:CreateFontString("T")
			vQC_ATTInfo.T:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vQC_ATTInfo.T:SetPoint("TOP", vQC_ATTInfo, 0, -8)
			vQC_ATTInfo.T:SetText("|cffc8c864Quest Completed by:|r")
			vQC_ATTInfo.AT = vQC_ATTInfo:CreateTexture(nil, "ARTWORK")
			vQC_ATTInfo.AT:SetSize(22,22)
			vQC_ATTInfo.AT:SetPoint("TOPLEFT", vQC_ATTInfo, 6, -6)
			vQC_ATTInfo.AT:SetTexture("Interface\\Addons\\QuestChecker\\Images\\logo_32x32")
		local vQC_ATTScroll = CreateFrame("ScrollFrame", "vQC_ATTScroll", vQC_ATTInfo, "UIPanelScrollFrameTemplate")
			vQC_ATTScroll:SetPoint("TOPLEFT", vQC_ATTInfo, 7, -31)
			vQC_ATTScroll:SetWidth(vQC_ATTInfo:GetWidth()-35)
			vQC_ATTScroll:SetHeight(vQC_ATTInfo:GetHeight()-37)
				vQC_ATTArea = CreateFrame("EditBox", "vQC_ATTArea", vQC_ATTScroll)
				vQC_ATTArea:SetWidth(vQC_MainFrame:GetWidth()-30)
				vQC_ATTArea:SetFont("Fonts\\FRIZQT__.TTF", 12)
				vQC_ATTArea:SetAutoFocus(false)
				vQC_ATTArea:SetMultiLine(true)
				vQC_ATTArea:EnableMouse(false)
			vQC_ATTScroll:SetScrollChild(vQC_ATTArea)

	--Display Result Possible Storyline Chains
	local vQC_QChains = CreateFrame("Frame", "vQC_QChains", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_QChains:SetBackdrop(DefaultBackdrop)
		vQC_QChains:SetSize(300,TmpHeight)
		vQC_QChains:ClearAllPoints()
		vQC_QChains:SetPoint("TOPRIGHT", vQC_MainFrame, vQC_QChains:GetWidth()-3, 0)
			vQC_QChains.B = vQC_QChains:CreateTexture(nil, "BACKGROUND")
			vQC_QChains.B:SetSize(vQC_QChains:GetWidth()-10,vQC_QChains:GetHeight()-10)
			vQC_QChains.B:SetPoint("CENTER", vQC_QChains, 0, 0)
			vQC_QChains.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Azerite")
			vQC_QChains.T = vQC_QChains:CreateFontString("T")
			vQC_QChains.T:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vQC_QChains.T:SetPoint("TOP", vQC_QChains, 0, -10)
			vQC_QChains.T:SetText("")
		local vQC_QChainS = CreateFrame("ScrollFrame", "vQC_QChainS", vQC_QChains, "UIPanelScrollFrameTemplate")
			vQC_QChainS:SetPoint("TOPLEFT", vQC_QChains, 7, -31)
			vQC_QChainS:SetWidth(vQC_QChains:GetWidth()-35)
			vQC_QChainS:SetHeight(vQC_QChains:GetHeight()-37)
				vQC_QCArea = CreateFrame("EditBox", "vQC_QCArea", vQC_QChainS)
				vQC_QCArea:SetWidth(vQC_QChains:GetWidth()-30)
				vQC_QCArea:SetFont("Fonts\\FRIZQT__.TTF", 12)
				vQC_QCArea:SetAutoFocus(false)
				vQC_QCArea:SetMultiLine(true)
				vQC_QCArea:EnableMouse(true)
				vQC_QCArea:SetText("")
			vQC_QChainS:SetScrollChild(vQC_QCArea)
		vQC_QChains:Hide()
			local vQC_QChainsX = CreateFrame("Button", "vQC_QChainsX", vQC_QChains, "UIPanelCloseButton")
				vQC_QChainsX:SetSize(32,32)
				vQC_QChainsX:SetPoint("TOPRIGHT", vQC_QChains, 0, 0)
				vQC_QChainsX:SetScript("OnClick", function() vQC_QChains:Hide() end)

------------------------------------------------------------------------
-- Build Other Frame/Misc
------------------------------------------------------------------------
		--MiniIcon for Map Pin
		local vQC_QuestWP = CreateFrame("Button", "vQC_QuestWP", vQC_Query7)
			vQC_QuestWP:SetSize(24, 24)
			vQC_QuestWP:SetNormalTexture("Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked")
			vQC_QuestWP:ClearAllPoints()
			vQC_QuestWP:SetPoint("RIGHT", vQC_Query7, -8, 0)
			vQC_QuestWP:SetScript("OnClick", function() vQC_Tooltips(2) end)
			vQC_QuestWP:SetScript("OnEnter", function() vQC_Tooltips("WPoint",vQC_QuestWP) end)
			vQC_QuestWP:SetScript("OnLeave", function() vQC_Tooltips(0) end)
			
		--MiniIcon for Have Chain
		local vQC_QuestChain = CreateFrame("Button", "vQC_QuestChain", vQC_Query6)
			vQC_QuestChain:SetSize(36, 36)
			vQC_QuestChain:SetNormalTexture("Interface\\RAIDFRAME\\UI-RAIDFRAME-ARROW")
			vQC_QuestChain:ClearAllPoints()
			vQC_QuestChain:SetPoint("RIGHT", vQC_Query6, -4, 0)
			vQC_QuestChain:SetScript("OnClick", function() if vQC_QChains:IsVisible() then vQC_QChains:Hide() else vQC_QChains:Show() end end)
			vQC_QuestChain:SetScript("OnEnter", function() vQC_Tooltips("QChain",vQC_QuestChain) end)
			vQC_QuestChain:SetScript("OnLeave", function() vQC_Tooltips(0) end)

		--For WoWHead
		local vQC_WHLinkIcon = CreateFrame("Button", "vQC_WHLinkIcon", vQC_ResultFrame)
			vQC_WHLinkIcon:SetSize(42,42)
			vQC_WHLinkIcon:SetNormalTexture("Interface\\LFGFRAME\\BattlenetWorking0")
			vQC_WHLinkIcon:SetPoint("TOPLEFT", vQC_ResultFrame, 2, -2)
			vQC_WHLinkIcon:SetScript("OnClick", function() vQC_Tooltips(1) end)
			vQC_WHLinkIcon:SetScript("OnEnter", function() vQC_Tooltips("WHLink",vQC_WHLinkIcon) end)
			vQC_WHLinkIcon:SetScript("OnLeave", function() vQC_Tooltips(0) end)
		local vQC_WHLinkF = CreateFrame("Frame", "vQC_WHLinkF", vQC_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
			vQC_WHLinkF:SetBackdrop(DefaultBackdrop)
			vQC_WHLinkF:SetSize(250,33)
			vQC_WHLinkF:SetPoint("TOPRIGHT", vQC_MainFrame, 0, 30)
				vQC_WHLinkF.B = vQC_WHLinkF:CreateTexture(nil, "BACKGROUND")
				vQC_WHLinkF.B:SetSize(vQC_WHLinkF:GetWidth()-4,vQC_WHLinkF:GetHeight()-4)
				vQC_WHLinkF.B:SetPoint("TOPLEFT", vQC_WHLinkF, 0, 0)
				vQC_WHLinkF.B:SetTexture("Interface\\BankFrame\\Bank-Background")
				local vQC_WHLinkTxt = CreateFrame("EditBox", "vQC_WHLinkTxt", vQC_WHLinkF, "InputBoxTemplate")
					vQC_WHLinkTxt:SetSize(vQC_WHLinkF:GetWidth()-20,19)
					vQC_WHLinkTxt:SetPoint("CENTER", vQC_WHLinkF, "CENTER", 2, 0)
					vQC_WHLinkTxt:SetAutoFocus(false)
					vQC_WHLinkTxt:SetMultiLine(false)
					vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QTBox:GetNumber())
			vQC_WHLinkF:Hide()
			
		--For Delay Search Animations
		local vQC_SearchLoad = CreateFrame("Frame", "vQC_SearchLoad", vQC_ResultFrame, BackdropTemplateMixin and "BackdropTemplate")
			vQC_SearchLoad:SetBackdropColor(1,0,1,0)
			vQC_SearchLoad:SetPoint("TOPRIGHT", vQC_ResultFrame, 3, 3)
			vQC_SearchLoad:SetSize(52,52)
				vQC_SearchLoad.T = vQC_SearchLoad:CreateFontString("T")
				vQC_SearchLoad.T:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
				vQC_SearchLoad.T:SetPoint("CENTER", vQC_SearchLoad, "CENTER", 0, 0)
				vQC_SearchLoad.T:SetText("|cffc8c864API|r")
			vQC_SearchLoad.Tb = vQC_SearchLoad:CreateTexture(nil, "ARTWORK")
			vQC_SearchLoad.Tb:SetTexture("Interface\\UNITPOWERBARALT\\Arcane_Circular_Frame")
			vQC_SearchLoad.Tb:SetAllPoints(vQC_SearchLoad)
				vQC_SearchLoad.AG = vQC_SearchLoad.Tb:CreateAnimationGroup()
					vQC_SearchLoad.AG:SetLooping("REPEAT")
				vQC_SearchLoad.CA = vQC_SearchLoad.AG:CreateAnimation("Rotation")
					vQC_SearchLoad.CA:SetDuration(5)
					vQC_SearchLoad.CA:SetDegrees(360)
			vQC_SearchLoad:Hide()
	
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
local vQC_OnUpdate = CreateFrame("Frame")
vQC_OnUpdate:RegisterEvent("ADDON_LOADED")
vQC_OnUpdate:SetScript("OnEvent", function(self, event, ...)
	
	if event == "ADDON_LOADED" then
		local TheEvents = {
			"QUEST_DETAIL", --1 selecting fresh quest
			"GOSSIP_CLOSED", --2 doesnt do much, basically gossip until quest selected
			"QUEST_FINISHED", --3 when closing the quest/accept quest
			"QUEST_DATA_LOAD_RESULT", --updates when quest log is viewed
			"QUEST_WATCH_LIST_CHANGED", --Minor when accept quest
			"QUEST_LOG_UPDATE", --opening questLog (cause QC to close)
			"QUESTLINE_UPDATE", --opening questLog
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
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vQC_Title.." v"..vQC_Version)
		SLASH_QC1, SLASH_QC2 = '/qc', '/qchecker'
		SlashCmdList["QC"] = OpenQC
		vQC_MainFrame:Hide()
		vQC_MiniQFrame:Hide()
		vQC_MiniWFrame:Hide()
		vQC_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
	end
	if event == "QUEST_WATCH_LIST_CHANGED" then
		CheckQuestAPI()
	end
	--print("Event Fired: "..event) --Debugging Purpose
	QuestInfo(event)
end)