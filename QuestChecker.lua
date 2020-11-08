--Thanks to Crieve for ATT (AllTheThings) Icon (if you have ATT installed, it will appear)

local vQC_Title = "|cffffff00"..strsub(GetAddOnMetadata("QuestChecker", "Title"),2).."|r"
local vQC_Version = GetAddOnMetadata("QuestChecker", "Version")
local _G = _G["C_QuestLog"]
--local TestNbr = "43341" --Uniting the Isle, popular BSI Starting Quest (Debugging Purpose)

local vQC_Tooltips = function(arg, frame)
	GameTooltip:Hide()
	GameTooltip:ClearLines()
	if arg == 0 then return end
	GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
	if arg == "ThisAdd" then msg = vQC_Title.." v"..vQC_Version end
	if arg == "QuestID" then msg = "Put in QuestID to check if you completed or not." end
	if arg == "ATTIcon" then msg = "You have |cffffff00AllTheThings|r!" end
	if arg == "QTBox" then msg = "Put in the Quest ID (Number Only)" end
	if arg == "CheckID" then msg = "Click here to see if other character has completed this." end
	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end

function OpenQuestID(a)
	if vQC_MFrame:IsVisible() and (QuestFrame:IsVisible() or QuestMapFrame:IsVisible()) then
		vQC_MFrame:Hide()
		return
	end
	vQC_MFrame:ClearAllPoints()
	vQC_MFrame:Show()
	vQC_QTBox:SetNumber(a)
	CheckQuest()
end

function OpenQC()
	if vQC_MFrame:IsVisible() then
		vQC_MFrame:Hide()
	else
		vQC_MFrame:ClearAllPoints()
		vQC_MFrame:SetPoint("CENTER", UIParent)
		if IsAddOnLoaded("AllTheThings") then 
			vQC_QFrameIATT:Show()
			vQC_MFrame:SetHeight(400)
		else
			vQC_QFrameIATT:Hide()
			vQC_IFrame:Hide()
			vQC_MFrame:SetHeight(186)
			vQC_MFrame.B:SetSize(vQC_MFrame:GetWidth()-6,vQC_MFrame:GetHeight()-6)
		end
		vQC_MFrame:Show()
	end
end

function QuestInfo(event)
	local questID = GetQuestID()
	if QuestMapFrame.DetailsFrame.questID ~= nil then
		questID = QuestMapFrame.DetailsFrame.questID
	end
	if questID == 0 then
		vQC_QWFrame:Hide()
		vQC_WFrame:Hide()
		vQC_MFrame:Hide()
		return
	end
	if QuestFrame:IsVisible() then vQC_QWFrame:Show() vQC_WFrame:Hide() vQC_QWFrame.N:SetText(questID) end
	if QuestMapFrame.DetailsFrame:IsVisible() then vQC_QWFrame:Hide() vQC_WFrame:Show() vQC_WFrame.N:SetText(questID) end
	--Need to go thru list to see what to keep/remove
	print("QuestID: "..questID.." - Event Fired: "..event) --Debugging Purpose
end

function CheckQuest()
	if (_G.GetTitleForQuestID(vQC_QTBox:GetNumber()) ~= nil) then
		if (select(1,_G.IsQuestFlaggedCompleted(vQC_QTBox:GetNumber()))) then
			msg = "Quest is completed\n\n"
		else
			msg = "Quest has not been completed\n\n"
		end
		if (_G.IsOnQuest(vQC_QTBox:GetNumber())) then IOQ = "Yes" else IOQ = "No" end
		if (_G.IsWorldQuest(vQC_QTBox:GetNumber())) then IWQ = "Yes" else IWQ = "No" end
		msg = msg .. "Title: |cffffff00" .. _G.GetTitleForQuestID(vQC_QTBox:GetNumber()) .. "|r\n" ..
			"Level: |cffffff00" .. _G.GetQuestDifficultyLevel(vQC_QTBox:GetNumber()) .. "|r\n" ..
			"On Quest? |cffffff00" .. IOQ .. "|r\n" ..
			"World Quest? |cffffff00" .. IWQ .. "|r\n"
	else
		msg = "Quest never existed or removed\n\nOR\n\nQuest is for opposite faction"
	end
	vQC_RFrame.T:SetText(msg)

	if IsAddOnLoaded("AllTheThings") then
		local MInfo, TeTab = {}, {}
		local Found = 1
		wipe(MInfo)
		local questID,
			q,
			u = vQC_QTBox:GetNumber(),
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

		if (MInfo == nil) then MInfo = "No Data" end
		if (type(MInfo) == "table") then MInfo = table.concat(MInfo, "\n") end
		if (type(MInfo) == "boolean" or type(MInfo) == "string") then MInfo = tostring(MInfo) end
		vQC_QTArea:SetText(MInfo) --Main
	end
end

local myIconPos = 0
local function UpdateMapBtn()
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
    vQC_MMButton:ClearAllPoints()
    vQC_MMButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
end

-- Build Frame - Quest Checker Main/Mini
local DefaultBackdrop = {
	edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
--MiniMap Button
local vQC_MMButton = CreateFrame("Button", "vQC_MMButton", Minimap)
	vQC_MMButton:SetFrameLevel(8)
	vQC_MMButton:SetSize(32, 32)
	vQC_MMButton:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
    vQC_MMButton:ClearAllPoints()
    vQC_MMButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
	vQC_MMButton:SetMovable(true)
	vQC_MMButton:RegisterForDrag("LeftButton")
		vQC_MMButton:SetScript("OnClick", function() OpenQC() end)
		vQC_MMButton:SetScript("OnEnter", function() vQC_Tooltips("ThisAdd",vQC_MMButton) end)
		vQC_MMButton:SetScript("OnLeave", function() vQC_Tooltips(0) end)
		vQC_MMButton:SetScript("OnDragStart", function()
			vQC_MMButton:StartMoving()
			vQC_MMButton:SetScript("OnUpdate", UpdateMapBtn)
		end)
		vQC_MMButton:SetScript("OnDragStop", function()
			vQC_MMButton:StopMovingOrSizing()
			vQC_MMButton:SetScript("OnUpdate", nil)
			UpdateMapBtn()
		end)
	
--Mini Frame
local vQC_QWFrame = CreateFrame("Frame", "vQC_QWFrame", QuestFrame, BackdropTemplateMixin and "BackdropTemplate")
	vQC_QWFrame:SetBackdrop(DefaultBackdrop)
	vQC_QWFrame:SetSize(160,33)
	vQC_QWFrame:ClearAllPoints()
	vQC_QWFrame:SetPoint("TOPRIGHT", QuestFrame, -3, -23)
		vQC_QWFrame.B = vQC_QWFrame:CreateTexture(nil, "BACKGROUND")
		vQC_QWFrame.B:SetSize(vQC_QWFrame:GetWidth()-6,vQC_QWFrame:GetHeight()-6)
		vQC_QWFrame.B:SetPoint("TOPLEFT", vQC_QWFrame, 3, -3)
		vQC_QWFrame.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Maw")
		vQC_QWFrame.T = vQC_QWFrame:CreateFontString("T")
		vQC_QWFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_QWFrame.T:SetPoint("LEFT", vQC_QWFrame, 5, 0)
		vQC_QWFrame.T:SetText("Quest ID:")
		vQC_QWFrame.N = vQC_QWFrame:CreateFontString("N")
		vQC_QWFrame.N:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_QWFrame.N:SetPoint("RIGHT", vQC_QWFrame, -27, 0)
		vQC_QWFrame.N:SetText()
		local vQC_QFIcon = CreateFrame("Button", "vQC_QFIcon", vQC_QWFrame)
			vQC_QFIcon:SetSize(30,30)
			vQC_QFIcon:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
			vQC_QFIcon:SetPoint("RIGHT", vQC_QWFrame, 0, 0)
			vQC_QFIcon:SetScript("OnClick", function() OpenQuestID(vQC_QWFrame.N:GetText()) end)
			vQC_QFIcon:SetScript("OnEnter", function() vQC_Tooltips("CheckID",vQC_QWFrame.N) end)
			vQC_QFIcon:SetScript("OnLeave", function() vQC_Tooltips(0) end)
local vQC_WFrame = CreateFrame("Frame", "vQC_WFrame", QuestMapFrame.DetailsFrame, BackdropTemplateMixin and "BackdropTemplate")
	vQC_WFrame:SetBackdrop(DefaultBackdrop)
	vQC_WFrame:SetSize(160,33)
	vQC_WFrame:ClearAllPoints()
	vQC_WFrame:SetPoint("TOPRIGHT", QuestMapFrame.DetailsFrame, 27, 45)
		vQC_WFrame.B = vQC_WFrame:CreateTexture(nil, "BACKGROUND")
		vQC_WFrame.B:SetSize(vQC_WFrame:GetWidth()-6,vQC_WFrame:GetHeight()-6)
		vQC_WFrame.B:SetPoint("TOPLEFT", vQC_WFrame, 3, -3)
		vQC_WFrame.B:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background-Maw")
		vQC_WFrame.T = vQC_WFrame:CreateFontString("T")
		vQC_WFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_WFrame.T:SetPoint("LEFT", vQC_WFrame, 5, 0)
		vQC_WFrame.T:SetText("Quest ID:")
		vQC_WFrame.N = vQC_WFrame:CreateFontString("N")
		vQC_WFrame.N:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		vQC_WFrame.N:SetPoint("RIGHT", vQC_WFrame, -27, 0)
		vQC_WFrame.N:SetText()
		local vQC_WFIcon = CreateFrame("Button", "vQC_WFIcon", vQC_WFrame)
			vQC_WFIcon:SetSize(30,30)
			vQC_WFIcon:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
			vQC_WFIcon:SetPoint("RIGHT", vQC_WFrame, 0, 0)
			vQC_WFIcon:SetScript("OnClick", function() OpenQuestID(vQC_WFrame.N:GetText()) end)
			vQC_WFIcon:SetScript("OnEnter", function() vQC_Tooltips("CheckID",vQC_WFrame.N) end)
			vQC_WFIcon:SetScript("OnLeave", function() vQC_Tooltips(0) end)

--Main Frame
local vQC_MFrame = CreateFrame("Frame", "vQC_MFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	vQC_MFrame:SetBackdrop(DefaultBackdrop)
	vQC_MFrame:SetSize(320,400)
	vQC_MFrame:ClearAllPoints()
	vQC_MFrame:SetPoint("CENTER", UIParent)
	vQC_MFrame:EnableMouse(true)
	vQC_MFrame:SetMovable(true)
	vQC_MFrame:RegisterForDrag("LeftButton")
	vQC_MFrame:SetScript("OnDragStart", function() vQC_MFrame:StartMoving() end)
	vQC_MFrame:SetScript("OnDragStop", function() vQC_MFrame:StopMovingOrSizing() end)
	vQC_MFrame:SetClampedToScreen(true)
		vQC_MFrame.B = vQC_MFrame:CreateTexture(nil, "BACKGROUND")
		vQC_MFrame.B:SetSize(vQC_MFrame:GetWidth()-6,vQC_MFrame:GetHeight()-6)
		vQC_MFrame.B:SetPoint("TOPLEFT", vQC_MFrame, 3, -3)
		vQC_MFrame.B:SetTexture("Interface\\AchievementFrame\\UI-GuildAchievement-Parchment")
		
	--Title Frame
	local vQC_TFrame = CreateFrame("Frame", "vQC_TFrame", vQC_MFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_TFrame:SetBackdrop(DefaultBackdrop)
		vQC_TFrame:SetSize(vQC_MFrame:GetWidth()-6,30)
		vQC_TFrame:ClearAllPoints()
		vQC_TFrame:SetPoint("TOP", vQC_MFrame, 0, -3)
			vQC_TFrame.B = vQC_TFrame:CreateTexture(nil, "BACKGROUND")
			vQC_TFrame.B:SetSize(vQC_TFrame:GetWidth()-10,vQC_TFrame:GetHeight()-4)
			vQC_TFrame.B:SetPoint("TOP", vQC_TFrame, 0, 0)
			vQC_TFrame.B:SetTexture("Interface\\BankFrame\\Bank-Background")
			vQC_TFrame.Ia = vQC_TFrame:CreateTexture(nil, "ARTWORK")
			vQC_TFrame.Ia:SetSize(64,64)
			vQC_TFrame.Ia:SetPoint("TOPLEFT", vQC_TFrame, 10, 35)
			vQC_TFrame.Ia:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver")
			vQC_TFrame.Ib = vQC_TFrame:CreateTexture(nil, "ARTWORK")
			vQC_TFrame.Ib:SetSize(64,64)
			vQC_TFrame.Ib:SetPoint("TOPLEFT", vQC_TFrame, 30, 35)
			vQC_TFrame.Ib:SetTexture("Interface\\TutorialFrame\\UI-TutorialFrame-QuestComplete")
			vQC_TFrame.T = vQC_TFrame:CreateFontString("T")
			vQC_TFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
			vQC_TFrame.T:SetPoint("CENTER", vQC_TFrame)
			vQC_TFrame.T:SetText(vQC_Title)
			local vQC_TFrameX = CreateFrame("Button", "vQC_TFrameX", vQC_TFrame, "UIPanelCloseButton")
				vQC_TFrameX:SetSize(32,32)
				vQC_TFrameX:SetPoint("RIGHT", vQC_TFrame, -2, 0)
				vQC_TFrameX:SetScript("OnClick", function() OpenQC() end)
				
	--Quest ID Input
	local vQC_QFrame = CreateFrame("Frame", "vQC_QFrame", vQC_MFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_QFrame:SetBackdrop(DefaultBackdrop)
		vQC_QFrame:SetSize(vQC_MFrame:GetWidth()-6,33)
		vQC_QFrame:ClearAllPoints()
		vQC_QFrame:SetPoint("TOP", vQC_TFrame, 0, 0-vQC_TFrame:GetHeight()+2)
		local vQC_QTBox = CreateFrame("EditBox", "vQC_QTBox", vQC_QFrame, "InputBoxTemplate")
			vQC_QTBox:SetPoint("CENTER", vQC_QFrame)
			vQC_QTBox:SetSize(80,20)
			vQC_QTBox:SetMaxLetters(50)
			vQC_QTBox:SetAutoFocus(false)
			vQC_QTBox:SetMultiLine(false)
			vQC_QTBox:SetNumeric(true)
			vQC_QTBox:SetNumber(TestNbr or 0)
			vQC_QTBox:SetScript("OnEnter", function() vQC_Tooltips("QTBox",vQC_QTBox) end)
			vQC_QTBox:SetScript("OnLeave", function() vQC_Tooltips(0) end)
			vQC_QTBox:SetScript("OnEnterPressed", function() CheckQuest() end)
			local vQC_QTBoxT = vQC_QFrame:CreateFontString("vQC_QTBoxT")
				vQC_QTBoxT:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
				vQC_QTBoxT:SetPoint("LEFT", vQC_QTBox, -65, 1)
				vQC_QTBoxT:SetText("Quest ID")
			local vQC_QTBoxB = CreateFrame("Button", "vQC_QTBoxB", vQC_QFrame, "UIPanelButtonTemplate")
				vQC_QTBoxB:SetSize(60,20)
				vQC_QTBoxB:SetPoint("RIGHT", vQC_QTBox, 65, 1)
				vQC_QTBoxB:SetText("Check")
				vQC_QTBoxB:SetScript("OnClick", function() CheckQuest() end)
		local vQC_QFrameIATT = CreateFrame("Button", "vQC_QFrameIATT", vQC_QFrame)
			vQC_QFrameIATT:SetSize(22,22)
			vQC_QFrameIATT:SetNormalTexture("Interface\\Addons\\QuestChecker\\Images\\logo_32x32")
			vQC_QFrameIATT:SetPoint("RIGHT", vQC_QFrame, -10, 0)
			vQC_QFrameIATT:SetScript("OnEnter", function() vQC_Tooltips("ATTIcon",vQC_QFrameIATT) end)
			vQC_QFrameIATT:SetScript("OnLeave", function() vQC_Tooltips(0) end)
			
	--Quest ID Result Frame
	local vQC_RFrame = CreateFrame("Frame", "vQC_RFrame", vQC_MFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_RFrame:SetBackdrop(DefaultBackdrop)
		vQC_RFrame:SetSize(vQC_MFrame:GetWidth()-6,120)
		vQC_RFrame:ClearAllPoints()
		vQC_RFrame:SetPoint("TOP", vQC_QFrame, 0, 0-vQC_QFrame:GetHeight()+2)
			vQC_RFrame.B = vQC_RFrame:CreateTexture(nil, "BACKGROUND")
			vQC_RFrame.B:SetSize(vQC_RFrame:GetWidth()-10,vQC_RFrame:GetHeight()-10)
			vQC_RFrame.B:SetPoint("CENTER", vQC_RFrame, 0, 0)
			vQC_RFrame.B:SetTexture("Interface\\GuildBankFrame\\GuildVaultBG")
			vQC_RFrame.T = vQC_RFrame:CreateFontString("T")
			vQC_RFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vQC_RFrame.T:SetPoint("CENTER", vQC_RFrame)

	--Quest ID Display Result (on Main Frame)
	local vQC_IFrame = CreateFrame("Frame", "vQC_IFrame", vQC_MFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_IFrame:SetBackdrop(DefaultBackdrop)
		vQC_IFrame:SetWidth(vQC_MFrame:GetWidth()-6)
		vQC_IFrame:SetHeight(vQC_MFrame:GetHeight()-(vQC_TFrame:GetHeight()+vQC_QFrame:GetHeight()+vQC_RFrame:GetHeight())-1)
		vQC_IFrame:ClearAllPoints()
		vQC_IFrame:SetPoint("TOP", vQC_RFrame, 0, 0-vQC_RFrame:GetHeight()+2)
			vQC_IFrame.B = vQC_IFrame:CreateTexture(nil, "BACKGROUND")
			vQC_IFrame.B:SetSize(vQC_IFrame:GetWidth()-10,vQC_IFrame:GetHeight()-10)
			vQC_IFrame.B:SetPoint("CENTER", vQC_IFrame, 0, 0)
			vQC_IFrame.B:SetTexture("Interface\\Tooltips\\CHATBUBBLE-BACKGROUND")
			vQC_IFrame.T = vQC_IFrame:CreateFontString("T")
			vQC_IFrame.T:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			vQC_IFrame.T:SetPoint("TOP", vQC_IFrame, 0, -8)
			vQC_IFrame.T:SetText("|cffc8c864List of Characters|r")
		local vQC_QScroll = CreateFrame("ScrollFrame", "vQC_QScroll", vQC_IFrame, "UIPanelScrollFrameTemplate")
			vQC_QScroll:SetPoint("TOPLEFT", vQC_IFrame, 7, -27)
			vQC_QScroll:SetWidth(vQC_IFrame:GetWidth()-35)
			vQC_QScroll:SetHeight(vQC_IFrame:GetHeight()-35)
				vQC_QTArea = CreateFrame("EditBox", "vQC_QTArea", vQC_QScroll)
				vQC_QTArea:SetWidth(vQC_MFrame:GetWidth()-30)
				vQC_QTArea:SetFont("Fonts\\FRIZQT__.TTF", 12)
				vQC_QTArea:SetAutoFocus(false)
				vQC_QTArea:SetMultiLine(true)
				vQC_QTArea:EnableMouse(false)
				vQC_QTArea:SetScript("OnEscapePressed", vQC_QTArea.ClearFocus)
			vQC_QScroll:SetScrollChild(vQC_QTArea)

-------------------------------------------------------
-- OnEvent
-------------------------------------------------------
local vQC_OnUpdate = CreateFrame("Frame")
	vQC_OnUpdate:RegisterEvent("PLAYER_LOGIN")
	local QEvents = {
		"QUEST_DETAIL", --1 selecting fresh quest
		"GOSSIP_CLOSED", --2 doesnt do much, basically gossip until quest selected
		"QUEST_FINISHED", --3 when closing the quest/accept quest
		"QUEST_DATA_LOAD_RESULT", --updates when quest log is viewed
		"QUEST_WATCH_LIST_CHANGED", --Minor when accept quest
		"QUEST_LOG_UPDATE", --opening questLog
		"QUESTLINE_UPDATE", --opening questLog
		"QUEST_PROGRESS", --ready to turn in quest
	}
	
vQC_OnUpdate:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vQC_Title.." v"..vQC_Version)
		for ev = 1, #QEvents do
			vQC_OnUpdate:RegisterEvent(QEvents[ev])
		end
		vQC_MFrame:Hide()
		vQC_QWFrame:Hide()
		vQC_WFrame:Hide()
	end
	QuestInfo(event)
end)

SLASH_QC1, SLASH_QC2 = '/qc', '/qchecker'
SlashCmdList["QC"] = OpenQC