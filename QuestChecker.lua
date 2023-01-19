----------------------------------------------------------------------------------------------------
                        --- AllTheThings Icon [Thanks to Crieve\Dylan] ---
                  --- AllTheThings Holiday Icon [Thanks to Dead Serious] ---
                        --- WOWHead Icon [Thanks to WOWHead] ---
        --- WOWHead Image can be found at:https://wow.zamimg.com/images/logos/big/new.png) ---
-------------------------------------------------------------------------------------------------------
	local vQC_AppTitle = "|CFFFFFF00"..strsub(GetAddOnMetadata("QuestChecker", "Title"),2).."|r v"..GetAddOnMetadata("QuestChecker", "Version")
	local vQC_Revision = "06302021_1418" --Ignore, its for my Debugging Purpose :)

------------------------------------------------------------------------
-- API Variables
------------------------------------------------------------------------
	local vC_QLogs = _G["C_QuestLog"]
	local vC_QLine = _G["C_QuestLine"]
	local vC_QTask = _G["C_TaskQuest"]
	local vC_CMaps = _G["C_Map"]
	local vC_CDaTi = _G["C_DateAndTime"]
------------------------------------------------------------------------
-- Table of Reuseable Icons
------------------------------------------------------------------------
	local ReuseIcons = {
		"|TInterface\\RAIDFRAME\\ReadyCheck-Ready:14|t",  					-- 1 Did Done
		"|TInterface\\RAIDFRAME\\ReadyCheck-NotReady:14|t",  				-- 2 Not Done
		"|TInterface\\COMMON\\Indicator-Green:14|t",  						-- 3 Selected
		"|TInterface\\COMMON\\Indicator-Red:14|t", 							-- 4 Not Selected
		"|TInterface\\HELPFRAME\\ReportLagIcon-Movement:20|t", 				-- 5 In Progress
		"|TInterface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked:18|t", 	-- 6 MapPin
		"|TInterface\\COMMON\\icon-noloot:18|t", 							-- 7 No Loot Bag
		"|TInterface\\Tooltips\\ReforgeGreenArrow:14|t", 					-- 8 Waiting (In Progress)
		"|TInterface\\GossipFrame\\ActiveQuestIcon:14|t", 					-- 9 Active Quest To Turn In
	}
------------------------------------------------------------------------
-- List of Fonts To Use (Might be more)
------------------------------------------------------------------------
	-- You can add your own style of Font to the list, but only ONE will be used.
	-- Find any instance of FontStyle[x] in the code and change to what you want accordingly
	local FontStyle = {
		"Fonts\\FRIZQT__.TTF",
		"Fonts\\ARIALN.ttf",
		"Fonts\\MORPHEUS.ttf",
		"Fonts\\skurri.ttf",
	}
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
	local Backdrop_C = { --Temp
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local Backdrop_NBgnd = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local Backdrop_NBdr = {
		bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	}
	
------------------------------------------------------------------------
-- Table of Frame Backdrops
------------------------------------------------------------------------	
	local CP, Re, TopRow, BotRow, GQL, OldvQCSL, OldWBNbr, myIconPos = 1, 0, 0, 0, 0, 0, 0, 0
	local mapID, StoryID, QC_Mem, MaxQuestID = 0, 0, 0, 70000
-- Local Font Size (for Frames)
	local Font_Lg = 14		--Large Font Size
	local Font_Md = 12		--Medium Font Size
	local Font_Sm = 10		--Small/Normal Font Size
-- Temp Number To Allow me to Change in future for "Resizing Window"
	local TmpHeight = 183	--Main Frame Height (One Influences All)
	local TmpWidth = 300	--Main Frame Width (One Influences All)
	local tHei = 7			--Gaps Between Title/Results
	local tRWi = 65			--Width of the Header (Temp)
-- Temp Solution Until I make a SavedVariable for this
	local LeftRightATT = "RIGHT" --(use either LEFT or RIGHT) for ATT Window position left or right of the Main Window
-- Random Image Bkgnd for World Boss Zone Title
------------------------------------------------------------------------
-- Debugging Only
------------------------------------------------------------------------
-- DEBUG if needed
	local DEBUG = false
	if DEBUG then local TestNbr = 25588 end
	function DeOutput(str, ...)
		local str = tostring(str)
		local arr = { ... }
		if #arr > 0 then
			for i, v in ipairs(arr) do
				str = str .. ", " .. v
			end
		end
		for _,name in pairs(CHAT_FRAMES) do
		   local frame = _G[name]
		   if frame.name == "DEWin" then -- You Need DEWin (ChatFrame) to view debugs
				frame:AddMessage(date("%H:%M.%S").." "..str)
		   end
		end
	end
------------------------------------------------------------------------
-- World Boss Settings
------------------------------------------------------------------------
	local WhatExpac = {
		"Classic",									-- 01 Not Used Classic
		"Burning Crusade",							-- 02 Not Used Burning Crusade
		"Wrath of Lich King",						-- 03 Not Used Wrath of Lich King
		"Cataclysm",								-- 04 Not Used Cataclysm
		"Mists of Pandaria",						-- 05 Mist of Pandaria
		"Warlords of Draenor",						-- 06 Warlords of Draenor
		"Legion",									-- 07 Legion
		"Battle of Azeroth",						-- 08 Battle of Azeroth
		"Shadowlands",								-- 09 Shadowlands
		"Dragonflight",								-- 10 Dragonflight
		"Broken Isles (Legion)",					-- 11 Legion
		"Argus (Legion)",							-- 12 Legion
		"Nazjatar (BfA)",							-- 13 Battle of Azeroth
		"Warfront: Arathi Highlands (BfA)",			-- 14 Battle of Azeroth
		"Warfront: Darkshore (BfA)",				-- 15 Battle of Azeroth
		"N'Zoth: Uldum (BfA)",						-- 16 Battle of Azeroth
		"N'Zoth: Vale of Eternal Blossoms (BfA)",	-- 17 Battle of Azeroth
		
	}
	local ExpacColor = {
		"000000",									-- 01 Not Used Classic
		"000000",									-- 02 Not Used Burning Crusade
		"000000",									-- 03 Not Used Wrath of Lich King
		"000000",									-- 04 Not Used Cataclysm
		"07FFA5",									-- 05 Mist of Pandaria
		"FF9982",									-- 06 Warlords of Draenor
		"DEFF45",									-- 07 Legion
		"65B3FF",									-- 08 Battle of Azeroth
		"CCCDD4",									-- 09 Shadowlands
		"CD7F32",									-- 10 Dragonflight
		"DEFF45",									-- 11 Legion
		"DEFF45",									-- 12 Legion
		"65B3FF",									-- 13 Battle of Azeroth
		"65B3FF",									-- 14 Battle of Azeroth
		"65B3FF",									-- 15 Battle of Azeroth
		"65B3FF",									-- 16 Battle of Azeroth
		"65B3FF",									-- 17 Battle of Azeroth
	}
	local WorldBossList = {
	--Mist of Pandaria	
		{ 32518, 5, 35, 814, "Nalak", "Nalak, The Storm Lord", 504, .600, .377, },								--01
		{ 32519, 5, 35, 826, "Oondasta", "Oondasta", 507, .499, .568, },										--02
		{ 33118, 5, 35, 861, "Ordos", "Ordos, Fire-God of the Yaungol", 504, .600, .377, },						--03
		{ 32098, 5, 35, 725, "Chief Salyis", "Salyis's Warband", 376, .707, .635, },							--04
		{ 32099, 5, 35, 691, "SHA OF ANGER", "Sha of Anger", 379, .535, .652, },								--05
		{ 33117, 5, 35, 857, "Chi Ji", "The Four Celestials", 554, .388, .552, },								--06
	--Warlord of Dreanor
		{ 37460, 6, 40, 1291, "Drov the Ruiner", "Drov the Ruiner", 543, .441, .399, },							--07
		{ 37464, 6, 40, 1262, "Rukhmar", "Rukhmar", 542, .370, .393, },											--08
		{ 39380, 6, 40, 1452, "SupremeLordKazzak", "Supreme Lord Kazzak", 534, .475, .221, },					--09
		{ 37462, 6, 40, 1211, "Tarlna The Ancient", "Tarlna the Ageless", 543, .470, .867, },					--10
	--Legion
		{ 43512, 7, 45, 1790, "Ana-Mouz", "Ana-Mouz", 680, .310, .655, },										--11
		{ 43193, 7, 45, 1774, "Calamir", "Calamir", 630, .377, .836, },											--12
		{ 43448, 7, 45, 1789, "Drugon the Frostblood", "Drugon the Frostblood", 650, .584, .726, },				--13
		{ 43985, 7, 45, 1795, "Flotsam", "Flotsam", 650, .492, .760, },											--14
		{ 42819, 7, 45, 1770, "Humongris", "Humongris", 641, .246, .696, },										--15
		{ 43192, 7, 45, 1769, "Levantus", "Levantus", 630, .430, .676, },										--16
		{ 43513, 7, 45, 1783, "Nazak the Fiend", "Na'zak the Fiend", 685, .360, .664, },						--17
		{ 42270, 7, 45, 1749, "Nithogg", "Nithogg", 634, .466, .300, },											--18
		{ 42779, 7, 45, 1763, "Sharthos", "Shar'thos", 641, .556, .432, },										--19
		{ 42269, 7, 45, 1756, "The Soultakers", "The Soultakers", 634, .782, .860, },							--20
		{ 44287, 7, 45, 1796, "Withered Jim", "Withered Jim", 630, .526, .808, },								--21
			--Broken Isles
		{ 47061, 11, 45, 1956, "FelReaver", "Apocron", 646, .592, .626, },										--22
		{ 46947, 11, 45, 1883, "Brutallus", "Brutallus", 646, .592, .284, },									--23
		{ 46948, 11, 45, 1884, "Malificus", "Malificus", 646, .598, .278, },									--24
		{ 46945, 11, 45, 1885, "Sivash", "Si'vash", 646, .896, .330, },											--25
			--Argus
		{ 49166, 12, 45, 2012, "InquisitorMeto", "Inquisitor Meto", 0, 0, 0, },									--26
		{ 49169, 12, 45, 2010, "MatronFolnuna", "Matron Folnuna", 0, 0, 0, },									--27
		{ 49167, 12, 45, 2011, "MistressAlluradel", "Mistress Alluradel", 0, 0, 0, },							--28
		{ 49170, 12, 45, 2013, "Occularus", "Occularus", 0, 0, 0, },											--29
		{ 49171, 12, 45, 2014, "Sotanathor", "Sotanathor", 0, 0, 0, },											--30
	--Battle of Azeroth
		{ 52163, 8, 50, 2199, "AzurethosTheWingedTyphoon", "Azurethos, The Winged Typhoon", 895, .620, .240, },	--31
		{ 52196, 8, 50, 2210, "DunegorgerKraulok", "Dunegorger Kraulok", 864, .443, .555, },					--32
		{ 52157, 8, 50, 2197, "HailstoneConstruct", "Hailstone Construct", 896, .492, .746, },					--33
		{ 52169, 8, 50, 2141, "Jiarak", "Ji'arak", 862, .690, .310, },											--34
		{ 52181, 8, 50, 2139, "Tzane", "T'zane", 863, .356, .336, },											--35
		{ 52166, 8, 50, 2198, "WarbringerYenajz", "Warbringer Yenajz", 942, .832, .496, },						--36
			--Nazjatar
		{ 56057, 13, 50, 2362, "Ulmath", "Ulmaththe Soulbinder", 1355, .842, .359, },							--37
		{ 56056, 13, 50, 2363, "Wekemara", "Wekemara", 1355, .428, .779, },										--38
			--Warfront: Arathi Highlands
		{ 52847, 14, 50, 2213, "DoomsHowl", "Doom's Howl", 14, .378, .402, },									--39
		{ 52847, 14, 50, 2213, "TheLionsRoar", "The Lion's Roar", 14, .355, .389, },							--40
			--Warfront: Darkshore
		{ 54895, 15, 50, 2345, "Ivus-the-Decayed", "Ivus the Decayed", 62, .414, .359, },						--41
		{ 54895, 15, 50, 2329, "Ivus-the-Forest-Lord", "Ivus the Forest Lord", 62, .414, .359, },				--42
			--Vale of Eternal Blossoms
		{ 58705, 16, 50, 2378, "Grand Empress Shekzeer", "Grand Empress Shek'zara", 1530, .590, .564, },		--43
			--Uldum
		{ 55466, 17, 50, 2381, "Vuklaz", "Vuk'laz the Earthbreaker", 1527, .457, .161, },						--44
	--Shadowlands
		{ 61816, 9, 60, 2431, "Mortanis", "Mortanis", 1536, .326, .654, },										--45
		{ 61814, 9, 60, 2433, "NurgashMuckformed", "Nurgash Muckformed", 1525, .272, .149, },					--46
		{ 61815, 9, 60, 2432, "Oranomonos", "Oranomonos the Everbranching", 1565, .206, .634, },				--47
		{ 61813, 9, 60, 2430, "Valinor", "Valinor, the Light of Eons", 1533, .263, .224, },						--48
			--The Maw
		{ 64531, 9, 60, 2456, "Mawsworn Caster", "Mor'geth, Tormentor of the Damned", 1543, .691, .442, },		--49
			--Zereth Mortis
		{ 65143, 9, 60, 2468, "Guardian of the First Ones", "Antros <Keeper of the Antecedents>", 1970, .488, .054, },	--50
	--Dragonflight
		{ 69927, 10, 70, 2517, "bazualthedradedflame", "Bazual, the Dreaded Flame", 2024, .794, .366, },		--51
		{ 69928, 10, 70, 2518, "liskanoththefuturebane", "Liskanoth, the Futurebane", 2085, .545, .688, },		--52
		{ 69929, 10, 70, 2515, "strunraantheskysmisery", "Strunraan, the Sky's Misery", 2023, .820, .760, },		--53
		{ 69930, 10, 70, 2506, "basrikrontheshalewing", "Basrikron, the Shale Win", 2022, .550, .777, },		--54
	}
------------------------------------------------------------------------
-- World Boss Checker
------------------------------------------------------------------------
function WorldBossCheck(arg)
	if DEBUG then DeOutput("WorldBossCheck") end
	
	if arg == 1 then
		if vQC_WBMain:IsVisible() then vQC_WBMain:Hide() return else vQC_WBMain:Show() end
	end
	
	vQC_WBTitle.Icon:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-"..WorldBossList[math.random(#WorldBossList)][5])

	-- Shorthand the _Gs
	local isQFC = vC_QLogs.IsQuestFlaggedCompleted
	local isTim = vC_QTask.GetQuestTimeLeftSeconds
	local isAdd = vC_QLogs.AddWorldQuestWatch
	local PLv = UnitLevel("player")
	local PHA = string.sub(select(2,UnitFactionGroup("player")),1,1)
	
--Still in Air....
--Maybe Detect Invasion/Warfront Timer?
--Legion Az 1187, Val 1188, HM 1189, St 1190
--BfA Zul 1193, Naz 1194, Vol 1195, TriS 1196, Dru 1197, StV 1198
--Darkshore 1203
--Arathi Highlands ???

	local TimerDash = false
	local TableRowCount = 0
	local HdrPos = -24
	for i = #WorldBossList, 1, -1 do
		-- Assign Variable to Table/Array Index(?) cuz I'm not gonna change [i][x] every freaking time, new data is added to Array :P
		local WBQu = WorldBossList[i][1] 	-- World Boss Quest ID
		local WBEx = WorldBossList[i][2]	-- Which Expansion Name
		local WBLv = WorldBossList[i][3] 	-- Minimium Level To See
		local WBEJ = WorldBossList[i][4] 	-- EncounterJournal ID
		local WBIm = WorldBossList[i][5] 	-- Image File Name
		local WBNa = WorldBossList[i][6] 	-- World Boss Actual Name
		local WBZo = WorldBossList[i][7] 	-- World Boss Zone ID
		local WBXc = WorldBossList[i][8] 	-- World Boss X ID
		local WBYc = WorldBossList[i][9] 	-- World Boss Y ID
		
		--Initialize Pull List
		local ExBool = (WBEx == 5 or WBEx == 6) and true or false
		local BossActive = (ExBool and isQFC(WBQu)) and true or (vC_QTask.IsActive(WBQu) and true or false)
		local QuestFinish = isQFC(WBQu) and true or false
		local TimeLeft = isTim(WBQu) and true or false
		local NoQuestID = WBQu == 99999 and true or false

		if BossActive or TimeLeft or QuestFinish or WBEx == 5 or WBEx == 6 and not NoQuestID then
--[[
	--To Do Soon, Tell User Can't See This WB due to Not Done with Quest
		if WBEx == 1 and PLv >= WBLv then 														-- MoP
		elseif WBEx == 2 and PLv >= WBLv then 													-- WoD
		elseif WBEx == 3 and (QFC(43341) or QFC(45727)) and PLv >= WBLv then 					-- Leg A/H
		elseif WBEx == 11 and QFC(46734) and PLv >= WBLv then 									-- BI A/H
		elseif WBEx == 12 and QFC(48461) and PLv >= WBLv then									-- Arg Inv A/H
		elseif WBEx == 4 and (QFC(51918) or QFC(52450)) and PLv >= WBLv and PHA == "A" then		-- BfA A
		elseif WBEx == 4 and (QFC(51916) or QFC(52451)) and PLv >= WBLv and PHA == "H" then		-- BfA H
		elseif WBEx == 13 and QFC(56031) and PLv >= WBLv and PHA == "A" then					-- BfA Naj A
		elseif WBEx == 13 and QFC(56030) and PLv >= WBLv and PHA == "H" then					-- BfA Naj H
		elseif WBEx == 14 and QFC(53198) and PLv >= WBLv and PHA == "A" then					-- BfA WFA A
		elseif WBEx == 14 and QFC(53212) and PLv >= WBLv and PHA == "H" then					-- BfA WFA H
		elseif WBEx == 15 and QFC(53847) and PLv >= WBLv and PHA == "A" then					-- BfA WFD A
		elseif WBEx == 15 and QFC(54042) and PLv >= WBLv and PHA == "H" then					-- BfA WFD H
		elseif WBEx == 16 and QFC(56472) and PLv >= WBLv then									-- BfA Uld A/H
		elseif WBEx == 17 and QFC(56771) and PLv >= WBLv then									-- BfA Val A/H
		elseif WBEx == 5 and QFC(57878) and PLv >= WBLv then									-- SL ??
		end
--]]

			local TimeLeft = (ExBool and vC_CDaTi.GetSecondsUntilWeeklyReset() or (isTim(WBQu) ~= nil and isTim(WBQu) or 0))
			local WQActive = ((ExBool and isQFC(WBQu)) and ReuseIcons[6] or (vC_QTask.IsActive(WBQu) and ReuseIcons[6] or ReuseIcons[2]))
			local QuestFinish = isQFC(WBQu) and ReuseIcons[1] or ReuseIcons[2]

			if _G["vWBMa"..i] == nil then
				local vWBMa = CreateFrame("Frame","vWBMa"..i,vQC_WBMain,BackdropTemplateMixin and "BackdropTemplate")
	--				vWBMa:SetBackdrop(Backdrop_NBgnd)
					vWBMa:SetSize(22,22)
					vWBMa:SetPoint("TOPLEFT",vQC_WBMain,4,HdrPos)
					local vWBMaB = CreateFrame("Button","vWBMaB"..i, _G["vWBMa"..i])
						vWBMaB:SetSize(20,20)
						vWBMaB:SetPoint("CENTER", "vWBMa"..i, "CENTER", 0, 0)		
						vWBMaB:SetNormalTexture("Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked")
						vWBMaB:SetScript("OnClick", function()
							if ExBool then MakePins(WBZo,WBXc,WBYc,WBNa) else isAdd(WBQu,1) end
							vQC_QuestID:SetNumber(WBQu)
							CheckQuestAPI()
						end)
						vWBMaB:SetScript("OnEnter", function()
							GameTooltip:ClearLines()
							GameTooltip:Hide()
							GameTooltip:SetOwner(_G["vWBMaB"..i],"ANCHOR_LEFT")
								vQC_WBTitle.Icon:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-"..WBIm)
							GameTooltip:AddLine(WhatExpac[WBEx].."\n\n")
							GameTooltip:AddDoubleLine("Boss: ",Colors(7,WBNa))
							GameTooltip:AddDoubleLine("Quest ID: ",Colors(7,WBQu))
							GameTooltip:AddDoubleLine("Zone: ",Colors(7,(WBZo ~= 0 and vC_CMaps.GetMapInfo(WBZo).name or "Unknown")))
							GameTooltip:AddDoubleLine("Coords: ",Colors(7,(WBZo ~= 0 and (WBXc*100)..", "..(WBYc*100) or "Unknown")))
							GameTooltip:AddLine("\nClick here to:\n"..Colors(2,(ExBool and "Create Map Pin to World Boss" or "Add World Quest Objective")))
							GameTooltip:Show()
						end)
						vWBMaB:SetScript("OnLeave", function()
							GameTooltip:ClearLines()
							GameTooltip:Hide()
						end)
			end
			if not _G["vWBMa"..i]:IsVisible() then _G["vWBMa"..i]:Show() end
			if _G["vWBQu"..i] == nil then
				local vWBQu = CreateFrame("Frame","vWBQu"..i,vQC_WBMain,BackdropTemplateMixin and "BackdropTemplate")
	--				vWBQu:SetBackdrop(Backdrop_NBgnd)
					vWBQu:SetSize(22,22)
					vWBQu:SetPoint("TOPLEFT",vQC_WBMain,22,HdrPos)
						vWBQu.Bkgnd = vWBQu:CreateTexture(nil, "OVERLAY")
						vWBQu.Bkgnd:SetSize(16,16)
						vWBQu.Bkgnd:SetPoint("CENTER", "vWBQu"..i, "CENTER", 1, 0)
						vWBQu.Bkgnd:SetTexture(string.sub(QuestFinish, 3, -6))
			else
				_G["vWBQu"..i].Bkgnd:SetTexture(string.sub(QuestFinish, 3, -6))
			end
			if not _G["vWBQu"..i]:IsVisible() then _G["vWBQu"..i]:Show() end

			if _G["vWBBN"..i] == nil then
				local vWBBN = CreateFrame("Frame","vWBBN"..i,vQC_WBMain,BackdropTemplateMixin and "BackdropTemplate")
	--				vWBBN:SetBackdrop(Backdrop_NBgnd)
					vWBBN:SetSize(225,22)
					vWBBN:SetPoint("TOPLEFT",vQC_WBMain,43,HdrPos)
						vWBBN.Text = vWBBN:CreateFontString("T")
						vWBBN.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
						vWBBN.Text:SetPoint("LEFT", "vWBBN"..i, 6, 0)
						vWBBN.Text:SetText(Colors(8,WBNa,WBEx))
			end
			if not _G["vWBBN"..i]:IsVisible() then _G["vWBBN"..i]:Show() end
			if _G["vWBTL"..i] == nil then
				local vWBTL = CreateFrame("Frame","vWBTL"..i,vQC_WBMain,BackdropTemplateMixin and "BackdropTemplate")
	--				vWBTL:SetBackdrop(Backdrop_NBgnd)
					vWBTL:SetSize(105,22)
					vWBTL:SetPoint("TOPLEFT",vQC_WBMain,246,HdrPos)
						vWBTL.Text = vWBTL:CreateFontString("vWBTL"..i)
						vWBTL.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
						vWBTL.Text:SetPoint("CENTER", "vWBTL"..i, 1, 0)
						vWBTL.Text:SetText(Colors(4,CDT(TimeLeft)))
				if vWBTL.Text:GetText() == "---" then TimerDash = true end
			else
				_G["vWBTL"..i].Text:SetText(Colors(4,CDT(TimeLeft)))
			end
			if not _G["vWBTL"..i]:IsVisible() then _G["vWBTL"..i]:Show() end
			HdrPos = HdrPos - 20
			TableRowCount = TableRowCount + 1 -- # of ACTUAL Frame Generated, not the Total # of Boss
		end
	end

	if (#WorldBossList <= OldWBNbr) then
		for i = #WorldBossList+1, OldWBNbr do
			_G["vWBMa"..i]:Hide()
			_G["vWBQu"..i]:Hide()
			_G["vWBBN"..i]:Hide()
			_G["vWBTL"..i]:Hide()
		end
	end
	OldWBNbr = #WorldBossList

	vQC_WBMain:SetSize(354,((20.1*TableRowCount)+29)) --Fix Height of World Boss once everything is displayed properly
	if TimerDash == true then
		TimerDash = false
		C_Timer.NewTimer(2, function() WorldBossCheck() end)
	end
end
------------------------------------------------------------------------
-- Frequent Updates via Event Watcher 'QUEST_WATCH_LIST_CHANGED'/Opens Addon
------------------------------------------------------------------------
function WatchQLogAct(arg)
	if DEBUG then DeOutput("WatchQLogAct") end

	if arg == 0 then -- Minimap Click Only
		if vQC_Main:IsVisible() then
			vQC_Main:Hide()
		else
			vQC_Main:Show()
			-- Keep For Holiday Modification Later
			-- TopRow = math.random(0,5)*64
			-- vQC_ATTTitle.Icon:SetTexCoord(TopRow/512, (TopRow+64)/512, 0/64, 64/64)
		end
	end
	
	if arg == 1 then -- QuestLog Click Only
		if QuestMapFrame.DetailsFrame:IsVisible() or QuestFrame:IsVisible() then
			if not vQC_Main:IsVisible() then vQC_Main:Show() end
		end
	end
	
	local questID = GetQuestID()
	if QuestMapFrame.DetailsFrame.questID ~= nil then questID = QuestMapFrame.DetailsFrame.questID end
	if questID == 0 then return end
	
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
-- Independent Query
------------------------------------------------------------------------
function CheckQuestAPI()
	if DEBUG then DeOutput("CheckQuestAPI") end
	vQC_NoResultsFound:Hide()
	vQC_YesResultsFound:Hide()
	vQC_StoryMain:Hide()
	vQC_ATTIconBG:SetBackdropColor(math.random(), math.random(), math.random(), 1)

	if not vQC_Query_Anim:IsVisible() then AnimToggle(0) end
	
	if vC_QLogs.GetTitleForQuestID(vQC_QuestID:GetNumber()) == nil then
		C_Timer.After(0, function()
			C_Timer.After(1, function()
				if vC_QLogs.GetTitleForQuestID(vQC_QuestID:GetNumber()) ~= nil then CheckQuestAPI() end
			end)
		end)
	end
	vQC_StoryMain:Hide()
	vQC_StoryTitle.Text:SetText("---")
	vQC_T_St.Text:SetText("---")
	vQC_T_XY.Text:SetText("---")
	vQC_T_SZ.Text:SetText("---")
	vQC_T_MZ.Text:SetText("---")
	Status = xpcall(QueryQuestAPI(), err)
end
------------------------------------------------------------------------
-- Query for QuestLog ID/Title, Bliz too slow to call via API
------------------------------------------------------------------------
function QueryQuestAPI()
	if DEBUG then DeOutput("QueryQuestAPI") end

	if (vC_QLogs.GetTitleForQuestID(vQC_QuestID:GetNumber()) ~= nil) then
		if (vC_QLogs.IsOnQuest(vQC_QuestID:GetNumber())) then
			vQC_ResultHeader.Text:SetText(ReuseIcons[5]..Colors(7," Quest In Progress"))
		else
			if (vC_QLogs.IsQuestFlaggedCompleted(vQC_QuestID:GetNumber())) then
				vQC_ResultHeader.Text:SetText(ReuseIcons[1]..Colors(7," Quest Completed"))
			else
				vQC_ResultHeader.Text:SetText(ReuseIcons[2]..Colors(7," Quest Not Completed"))
			end
		end
		vQC_T_ID.Text:SetText(vQC_QuestID:GetNumber()) -- Quest ID
		vQC_T_Na.Text:SetText("|CFFFFFF00|Hquest:"..vQC_QuestID:GetNumber()..":::::::::::::::|h"..vC_QLogs.GetTitleForQuestID(vQC_QuestID:GetNumber()).."|h|r") -- Quest Name
		--This is bugging out on tooltip, not sure exactly why
	--		vQC_T_Na:HookScript("OnEnter", function()
	--			GameTooltip:ClearLines()
	--			GameTooltip:Hide()
	--				GameTooltip:SetOwner(vQC_T_Na, "ANCHOR_CURSOR")
	--				GameTooltip:SetHyperlink("quest:"..vQC_QuestID:GetNumber()..":0:0:0:0:0:0:0")
	--			GameTooltip:Show()
	--		end)
	--		vQC_T_Na:HookScript("OnLeave", function() GameTooltip:Hide() end)
		vQCB_T_Lv.Text:SetText(vC_QLogs.GetQuestDifficultyLevel(vQC_QuestID:GetNumber())) -- Quest Level
		vQC_NoResultsFound:Hide()
		vQC_YesResultsFound:Show()
		Status = xpcall(GetQuestLineID(), err) -- Query GetQuestLineID
	else
		vQC_ResultHeader.Text:SetText(Colors(7,"Quest ID # ")..vQC_QuestID:GetNumber()..Colors(7," has:"))
		vQC_NoResultsFound:Show()
		vQC_YesResultsFound:Hide()
		AnimToggle(1)
	end
	-- Query AllTheThings SavedVariables
	Status = xpcall(ATTQueryDatabase(), err)
	if vQC_WHLinkBox:IsVisible() and tonumber(string.sub(vQC_WHLinkTxt:GetText(),19)) ~= vQC_QuestID:GetNumber() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
	end
	vQC_QuestID:ClearFocus()
end
------------------------------------------------------------------------
-- Query from GetQuestZoneID, GetQuestLineInfo & GetMapInfo
------------------------------------------------------------------------
function GetQuestLineID()
	if DEBUG then DeOutput("GetQuestLineID") end
	GQL = GQL + 1
	if Re == 0 then mapID = vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber()) end
	-- Is this Quest in Storyline Chains? (and X,Y, Subzone, and Zone)
	mapID = vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber())
	
	if mapID then
		StoryID = vC_QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber()))
		if StoryID then
			-- Show Storyline Window
			vQC_StoryMain:Show()
			-- Make a Title for the Storyline Window
			vQC_StoryTitle.Text:SetText(Colors(4,StoryID.questLineName))
			-- Make an Text of Storyline
			vQC_T_St.Text:SetText(vQC_StoryTitle.Text:GetText())
			-- Mark an X,Y Coord
			vQC_T_XY.Text:SetText(mapID and string.format("%.1f",StoryID.x*100).." "..string.format("%.1f",StoryID.y*100) or "---")
			-- Show Subzone Name
			vQC_T_SZ.Text:SetText(mapID and vC_CMaps.GetMapInfo(vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).name or "---")
			-- Show Zone Name (59931 has sub, no parent)
			vQC_T_MZ.Text:SetText(mapID and (vC_CMaps.GetMapInfo(vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).parentMapID ~= 0 and vC_CMaps.GetMapInfo(vC_CMaps.GetMapInfo(vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).parentMapID).name) or "---")
			-- Check/Pull Storyline if any
			Status = xpcall(ShowChainQuest(), err)
		else
			if Re < 5 then
				Re = Re + 1
				if GQL < 6 then
					C_Timer.NewTimer(1, function() GetQuestLineID() end)
				else --Odd Case where SOME QuestLineID would get "Stuck" on particular StoryLine Query, stop the queue if it failed 5 tries
					AnimToggle(1)
					vQC_T_St.Text:SetText(Colors(1,"Issue with Query, Try Again Later..."))
					GQL = 0
				end
			else
				if Re == 5 then Re = 0 end
			end
		end
	else
		vQC_StoryMain:Hide()
		vQC_StoryTitle.Text:SetText("---")
		vQC_T_St.Text:SetText("---")
		vQC_T_XY.Text:SetText("---")
		vQC_T_SZ.Text:SetText("---")
		vQC_T_MZ.Text:SetText("---")
		AnimToggle(1)
	end
	if vQC_T_XY.Text:GetText() == "---" then vQC_MapPinIcon:Hide() else vQC_MapPinIcon:Show() end
	if vQC_T_ID.Text:GetText() == "---" then vQC_ATTPin:Hide() else vQC_ATTPin:Show() end
	Re = 0
end
------------------------------------------------------------------------
-- Query the Storyline
------------------------------------------------------------------------
local NStoryLineCount = 0
function ShowChainQuest()
	if DEBUG then DeOutput("ShowChainQuest") end
	if not vQC_StoryMain:IsVisible() then
		GetQuestLineID()
		return
	end

	local vQCSL = {}
	if vQC_QuestID:IsEnabled() then ToggleInputs(0) end
	
	wipe(vQCSL)
	vQCSL = vC_QLine.GetQuestLineQuests(vC_QLine.GetQuestLineInfo(vQC_QuestID:GetNumber(),vC_QTask.GetQuestZoneID(vQC_QuestID:GetNumber())).questLineID)
	
	local OStoryLineCount = NStoryLineCount
	NStoryLineCount = #vQCSL
	
	HdrPos = 0
	for i = 1, #vQCSL do
		local DidQuestIcon = (vC_QLogs.IsComplete(vQCSL[i]) and ReuseIcons[9] or (vC_QLogs.GetLogIndexForQuestID(vQCSL[i]) and ReuseIcons[8] or(vC_QLogs.IsQuestFlaggedCompleted(vQCSL[i]) and ReuseIcons[1] or ReuseIcons[2])))
		
		local QuestNa = (vC_QLogs.GetTitleForQuestID(vQCSL[i]) == nil and Colors(1,"Querying Data...") or (vQCSL[i] == vQC_QuestID:GetNumber() and Colors(2,vC_QLogs.GetTitleForQuestID(vQCSL[i]))) or Colors(6,vC_QLogs.GetTitleForQuestID(vQCSL[i])))
		
		-- Information/Clickable Icon
		if _G["vSLIn"..i] == nil then --22/0
			local vSLIn = CreateFrame("Frame","vSLIn"..i,vQC_SLContent,BackdropTemplateMixin and "BackdropTemplate")
		--		vSLIn:SetBackdrop(Backdrop_NBgnd)
				vSLIn:SetSize(22,22)
				vSLIn:SetPoint("TOPLEFT",vQC_SLContent,0,HdrPos)
				local vSLInB = CreateFrame("Button","vSLInB"..i, _G["vSLIn"..i])
					vSLInB:SetSize(14,14)
					vSLInB:SetPoint("CENTER", "vSLIn"..i, "CENTER", 0, 0)
					vSLInB:SetNormalTexture("Interface\\FriendsFrame\\InformationIcon")
					vSLInB:SetScript("OnClick", function()
						vQC_QuestID:SetNumber(vQCSL[i])
						CheckQuestAPI()
					end)
					vSLInB:SetScript("OnEnter", function()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
					GameTooltip:SetOwner(_G["vSLInB"..i],"ANCHOR_LEFT")
					--13565
						GameTooltip:AddLine(DidQuestIcon..vQC_StoryTitle.Text:GetText().."\n\n")
						GameTooltip:AddDoubleLine("Name: ",Colors(7,QuestNa))
						GameTooltip:AddDoubleLine("ID: ",Colors(7,vQCSL[i]))
						GameTooltip:AddLine("\nClick here for more details!")
					GameTooltip:Show()
					end)
					vSLInB:SetScript("OnLeave", function()
						GameTooltip:ClearLines()
						GameTooltip:Hide()
					end)
		else
				_G["vSLInB"..i]:SetScript("OnClick", function()
					vQC_QuestID:SetNumber(vQCSL[i])
					CheckQuestAPI()
				end)
				_G["vSLInB"..i]:SetScript("OnEnter", function()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
					GameTooltip:SetOwner(_G["vSLInB"..i],"ANCHOR_LEFT")
						GameTooltip:AddLine(DidQuestIcon..vQC_StoryTitle.Text:GetText().."\n\n")
						GameTooltip:AddDoubleLine("Name: ",Colors(7,QuestNa))
						GameTooltip:AddDoubleLine("ID: ",Colors(7,vQCSL[i]))
						GameTooltip:AddLine("\nClick here for more details!")
					GameTooltip:Show()
				end)
				_G["vSLInB"..i]:SetScript("OnLeave", function()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
				end)
		end
		if strfind(QuestNa,"Querying Data...") then _G["vSLInB"..i]:Hide() else _G["vSLInB"..i]:Show() end
		if not _G["vSLIn"..i]:IsVisible() then _G["vSLIn"..i]:Show() end
		
		-- Index'ng Number
		if _G["vSLi"..i] == nil then --34/22
			local vSLi = CreateFrame("Frame","vSLi"..i,vQC_SLContent,BackdropTemplateMixin and "BackdropTemplate")
		--		vSLi:SetBackdrop(Backdrop_NBgnd)
				vSLi:SetSize(34,22)
				vSLi:SetPoint("TOPLEFT",vQC_SLContent,20,HdrPos)
					vSLi.Text = vSLi:CreateFontString("vSLi"..i)
					vSLi.Text:SetFont(FontStyle[1], Font_Sm)
					vSLi.Text:SetPoint("RIGHT", "vSLi"..i, -4, 0)
					vSLi.Text:SetText(Colors(6,i))
		else
			_G["vSLi"..i].Text:SetText(Colors(6,i))
		end
		if not _G["vSLi"..i]:IsVisible() then _G["vSLi"..i]:Show() end
		
		-- Check, X or ? for Quest Progress
		if _G["vSLDo"..i] == nil then --22/56
			local vSLDo = CreateFrame("Frame","vSLDo"..i,vQC_SLContent,BackdropTemplateMixin and "BackdropTemplate")
		--		vSLDo:SetBackdrop(Backdrop_NBgnd)
				vSLDo:SetSize(22,22)
				vSLDo:SetPoint("TOPLEFT",vQC_SLContent,53,HdrPos)
					vSLDo.Icon = vSLDo:CreateTexture(nil, "OVERLAY")
					vSLDo.Icon:SetSize(14,14)
					vSLDo.Icon:SetPoint("CENTER", "vSLDo"..i, "CENTER", 0, 0)
					vSLDo.Icon:SetTexture(string.sub(DidQuestIcon, 3, -6))

		else
			_G["vSLDo"..i].Icon:SetTexture(string.sub(DidQuestIcon, 3, -6))
		end
		if not _G["vSLDo"..i]:IsVisible() then _G["vSLDo"..i]:Show() end
		
		-- Quest ID
		if _G["vSLQI"..i] == nil then --56/104
			local vSLQI = CreateFrame("Frame","vSLQI"..i,vQC_SLContent,BackdropTemplateMixin and "BackdropTemplate")
		--		vSLQI:SetBackdrop(Backdrop_NBgnd)
				vSLQI:SetSize(56,22)
				vSLQI:SetPoint("TOPLEFT",vQC_SLContent,74,HdrPos)
					vSLQI.Text = vSLQI:CreateFontString("vSLQI"..i)
					vSLQI.Text:SetFont(FontStyle[1], Font_Sm)
					vSLQI.Text:SetPoint("LEFT", "vSLQI"..i, 5, 0)
					vSLQI.Text:SetText(Colors(6,vQCSL[i]))
		else
			_G["vSLQI"..i].Text:SetText(Colors(6,vQCSL[i]))
		end
		if not _G["vSLQI"..i]:IsVisible() then _G["vSLQI"..i]:Show() end
		
		-- Quest Name
		if _G["vSLQN"..i] == nil then --163/160
			local vSLQN = CreateFrame("Frame","vSLQN"..i,vQC_SLContent,BackdropTemplateMixin and "BackdropTemplate")
		--		vSLQN:SetBackdrop(Backdrop_NBgnd)
				vSLQN:SetSize(139,22)
				vSLQN:SetPoint("TOPLEFT",vQC_SLContent,129,HdrPos)
					vSLQN.Text = vSLQN:CreateFontString("vSLQN"..i)
					vSLQN.Text:SetFont(FontStyle[1], Font_Sm)
					vSLQN.Text:SetPoint("LEFT", "vSLQN"..i, 5, 0)
					vSLQN.Text:SetText(QuestNa)
		else
			_G["vSLQN"..i].Text:SetText(QuestNa)
		end
		if not _G["vSLQN"..i]:IsVisible() then _G["vSLQN"..i]:Show() end
		
		HdrPos = HdrPos - 18
	end
	
	if NStoryLineCount < OStoryLineCount then
		for i = NStoryLineCount+1, OStoryLineCount do
			_G["vSLIn"..i]:Hide()
			_G["vSLi"..i]:Hide()
			_G["vSLDo"..i]:Hide()
			_G["vSLQI"..i]:Hide()
			_G["vSLQN"..i]:Hide()
		end
	end
	
	OldTitle = vQC_StoryTitle.Text:GetText()
	vQC_StoryTitle.Text:SetText(OldTitle..Colors(4," ["..NStoryLineCount.."]"))
	
	local QueryFin = true
	for i = 1, #vQCSL do
		if strfind(_G["vSLQN"..i].Text:GetText(),"Querying Data...") then
			QueryFin = false
			Status = xpcall(TryQueryAgain(i,vQCSL[i],1,5),err)
		end
	end

	if QueryFin then
		AnimToggle(1)
		ToggleInputs(1)
	else
		C_Timer.After(
			6,
			function()
				AnimToggle(1)
				ToggleInputs(1)
		end)
	end
	
end
------------------------------------------------------------------------
-- Query Again if still have "Querying Data"
------------------------------------------------------------------------
function TryQueryAgain(i,q,mi,ma)
	if DEBUG then DeOutput("TryQueryAgain",i,q) end
	local tVar = _G["vSLQN"..i]:GetName()
	tVar = C_Timer.NewTicker(
		mi,
		function()
			if strfind(_G["vSLQN"..i].Text:GetText(),"Querying Data...") or strfind(_G["vSLQN"..i].Text:GetText(),"Server Failed to Response...") then
				_G["vSLInB"..i]:Hide()
			else
				_G["vSLInB"..i]:Show()
			end
			if strfind(_G["vSLQN"..i].Text:GetText(),"Querying Data...") then
				QuestNa = _G["vSLQN"..i].Text:SetText(vC_QLogs.GetTitleForQuestID(q) == nil and Colors(1,"Querying Data...") or (q == vQC_QuestID:GetNumber() and Colors(2,vC_QLogs.GetTitleForQuestID(q))) or Colors(6,vC_QLogs.GetTitleForQuestID(q)))
				_G["vSLInB"..i]:SetScript("OnEnter", function()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
					GameTooltip:SetOwner(_G["vSLInB"..i],"ANCHOR_LEFT")
						GameTooltip:AddLine(vQC_StoryTitle.Text:GetText().."\n\n")
						GameTooltip:AddDoubleLine("Name: ",Colors(7,QuestNa))
						GameTooltip:AddDoubleLine("ID: ",Colors(7,q))
						GameTooltip:AddLine("\nClick here for more details!")
					GameTooltip:Show()
				end)
			end
			if tVar._remainingIterations == 1 then
				if strfind(_G["vSLQN"..i].Text:GetText(),"Querying Data...") then
					_G["vSLQN"..i].Text:SetText(string.gsub(_G["vSLQN"..i].Text:GetText(),"Querying Data...","Server Failed to Response..."))
					_G["vSLInB"..i]:Hide()
				end
				tVar:Cancel()
			end
		end,
		ma)
end
------------------------------------------------------------------------
-- Query Information from AllTheThings SavedVariables if Quest Completed
------------------------------------------------------------------------
function ATTQueryDatabase()
	if DEBUG then DeOutput("ATTQueryDatabase") end
	if IsAddOnLoaded("AllTheThings") then
		local MInfo, TeTab, tMInfo = {}, {}, {}
		local Found = 1
		wipe(MInfo)
		local u = vQC_QuestID:GetNumber()
		for a, b in pairs(ATTCharacterData) do
		   if type(b["Quests"]) == "table" and b["Quests"][u] then
			  tinsert(MInfo,b["text"])
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
-- Color Choice
------------------------------------------------------------------------
function Colors(c,t,e)
	-- 1R 2G 3B 4Y 5B 6W 7Custom 8Inputs
	if c == 8 then
		ColorChoice = ExpacColor[e]
	else
		local ColorSelect = { "FF0000", "00FF00", "0000FF", "FFFF00", "000000", "FFFFFF", "CCCC66", }
		ColorChoice = ColorSelect[c]
	end
	return "|cFF"..ColorChoice..(t == nil and "" or t).."|r"
end
------------------------------------------------------------------------
-- Convert Epoch Sec to D/H:M.S
------------------------------------------------------------------------
function CDT(T)
	if T == 0 then return "---" end
	local d = floor(T/86400)
	local h = floor(mod(T, 86400)/3600)
	local m = floor(mod(T,3600)/60)
	local s = floor(mod(T,60))
	return format("%dd %02dh %02dm %02ds",d,h,m,s)
end
------------------------------------------------------------------------
-- Memory Check/Indicator and Dump if needed (Quest Query can be.... annoying)
------------------------------------------------------------------------
function WatchMemoryCount()
	if DEBUG then DeOutput("WatchMemoryCount") end
	QC_Mem = GetAddOnMemoryUsage("QuestChecker")
	if QC_Mem < 127 then vQC_Quest_MemIcon:Hide() else vQC_Quest_MemIcon:Show() end
	if QC_Mem > 512 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Red") end
	if QC_Mem < 512 and QC_Mem > 256 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Yellow") end
	if QC_Mem < 256 and QC_Mem > 128 then vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green") end
	if QC_Mem > 256 and not InCombatLockdown() then
		if DEBUG then print(strsub(GetAddOnMetadata("QuestChecker", "Title"),2)..Colors(6," - Dump Mem: ")..Colors(2,(QC_Mem > 999 and format("%.1f%s", QC_Mem / 1024, " mb") or format("%.0f%s", QC_Mem, " kb")))) end
		collectgarbage("collect")
		vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green")
	end
end
------------------------------------------------------------------------
-- Game ToolTip Simplified
------------------------------------------------------------------------
function ToolTipsOnly(f)
	--if DEBUG then DeOutput("ToolTipsOnly") end
	GameTooltip:ClearLines()
	GameTooltip:Hide()
	if f == 0 then return end
	if vQC_Main:GetCenter() > (UIParent:GetWidth() / 2) then
		GameTooltip:SetOwner(f, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
	end
	if f == vQC_ATTPin then msg = "Click here to bring up possible Quest Source from ATT if available.\n\nMight need to change to DEBUG mode to see the chain if it shows completed." end
	if f == vQC_WhereIcon then msg = "Print out your location (Zone ID and XY Coords)" end
	if f == vQC_WBMainRefresh then msg = "Click here to Refresh World Boss List..." end 
	if f == vQC_WBMapB then msg = vQC_WBMapB:GetText() end
	if f == vQC_MiniMap then msg = vQC_AppTitle.."\n\n"..Colors(2,"\/qc ?").." for more options" end
	if f == vQC_MiniQ then msg = "Quest ID: "..Colors(2,vQC_MiniQ.Text:GetText()).."\n\nClick to check Quest." end
	if f == vQC_MiniW then msg = "Quest ID: "..Colors(2,vQC_MiniW.Text:GetText()).."\n\nClick to check Quest." end
	if f == vQC_MapPinIcon then msg = "Pin coord, |cFFFF00FF"..vQC_T_XY.Text:GetText().."|r, to the map" end
	if f == vQC_Quest_MemIcon then msg = Colors(6,"Current: ")..Colors(2,(QC_Mem > 999 and format("%.1f%s", QC_Mem / 1024, " mb") or format("%.0f%s", QC_Mem, " kb"))) end
	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end
------------------------------------------------------------------------
-- Increment/Decrement the Value
------------------------------------------------------------------------
function QuestUpDown(arg)
	if DEBUG then DeOutput("QuestUpDown") end
	local QNbr = vQC_QuestID:GetNumber()
	if arg == 1 then 
		QNbr = QNbr + 1
		if QNbr >= MaxQuestID then QNbr = 0 end
	end
	if arg == 0 then
		QNbr = QNbr - 1
		if QNbr == -1 then QNbr = MaxQuestID end
	end
	vQC_QuestID:SetNumber(QNbr)
	if vQC_WHLinkBox:IsVisible() and tonumber(string.sub(vQC_WHLinkTxt:GetText(),19)) ~= vQC_QuestID:GetNumber() then
		vQC_WHLinkTxt:SetText("wowhead.com/quest="..vQC_QuestID:GetNumber())
	end
	Status = xpcall(CheckQuestAPI(), err)
end
------------------------------------------------------------------------
-- Animations Toggle
------------------------------------------------------------------------
function AnimToggle(arg)
	if DEBUG then DeOutput("AnimToggle",arg) end
	if arg == 0 then
		vQC_Query_Anim:Show()
		vQC_Query_Anim.AG:Play()
	end
	if arg == 1 then
		vQC_Query_Anim.AG:Stop()
		vQC_Query_Anim:Hide()
	end
end
------------------------------------------------------------------------
-- Toggle Buttons To Prevent Multiple Query Loop
------------------------------------------------------------------------
function ToggleInputs(arg)
	if DEBUG then DeOutput("ToggleInputs") end
	if arg == 0 then
		vQC_QuestID:Disable()
		vQC_QID_Dec:Disable()
		vQC_QID_Inc:Disable()
		vQC_QuestID_Query:Disable()
		if DEBUG then vQC_DebugIcon:Disable() end
	end
	if arg == 1 then
		vQC_QuestID:Enable()
		vQC_QID_Dec:Enable()
		vQC_QID_Inc:Enable()
		vQC_QuestID_Query:Enable()
		if DEBUG then vQC_DebugIcon:Enable() end
	end
end
------------------------------------------------------------------------
-- WOWHead Link Display
------------------------------------------------------------------------
function WHLink()
 	if DEBUG then DeOutput("WHLink") end
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
function MakePins(Q,X,Y,B)
	if DEBUG then DeOutput("MakePins") end
	local Qz = ((X == 0 and Y == 0) and vC_QTask.GetQuestZoneID(Q) or Q)
	local Xy = ((X == 0 and Y == 0) and vC_QLine.GetQuestLineInfo(Q,vC_QTask.GetQuestZoneID(Q)).x or X)
	local Yx = ((X == 0 and Y == 0) and vC_QLine.GetQuestLineInfo(Q,vC_QTask.GetQuestZoneID(Q)).y or Y)
	local Bo = ((X == 0 and Y == 0) and vQC_T_Na.Text:GetText() or B)
	if IsAddOnLoaded("TomTom") then
		TomTom:AddWaypoint( Qz, Xy, Yx, { title = Bo, persistent = nil, world = true, from = vQC_AppTitle, } )
	else
		vC_CMaps.SetUserWaypoint( UiMapPoint.CreateFromCoordinates( Qz, Xy, Yx ) )
		C_SuperTrack.SetSuperTrackedUserWaypoint(true)
	end
end
------------------------------------------------------------------------
-- Mini Map Position when Dragging
------------------------------------------------------------------------
function UpdateMiniMapButton(arg)
    local Xpoa, Ypoa = GetCursorPosition()
    local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
    Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
    Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
    myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
	if arg == 1 then
		vQC_MiniMap:ClearAllPoints()
		vQC_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
	end
end
------------------------------------------------------------------------
-- Best uiMapID for Player
------------------------------------------------------------------------
function WhereAmI()
	if not WorldMapFrame:IsVisible() then WorldMapFrame:Show() WorldMapFrame:Hide() end
	local a = C_Map.GetBestMapForUnit("player") -- which zone are you in?
	local b = C_Map.GetMapInfo(a).name -- Name of the SubZone
	local c = C_Map.GetMapInfo(a).parentMapID == 0 and "Cosmics" or C_Map.GetMapInfo(C_Map.GetMapInfo(a).parentMapID).name -- Name of the Zone
	local e = C_Map.GetPlayerMapPosition(a,"player") -- get XY position, if any
	local f = e ~= nil and format("%.3f",select(1,e:GetXY()))*100 or 0 -- Get X
	local g = e ~= nil and format("%.3f",select(2,e:GetXY()))*100 or 0 -- Get Y
	print(b..", "..c.." - #"..a.." @ "..f..", "..g)
end
------------------------------------------------------------------------
-- NPC Info
------------------------------------------------------------------------
function WhoIsThis()
	if UnitName("target") == nil then return end
	local guid, name = UnitGUID("target"), UnitName("target")
	local type, _, _, _, _, npc_id, _ = strsplit("-",guid)
	if type == "Creature" then
		WhereAmI()
		print("NPC: " .. Colors(7,name) .. " [ " .. Colors(7,npc_id) .. " ]")
	end
end
------------------------------------------------------------------------
-- Mini Map Button
------------------------------------------------------------------------
	local vQC_MiniMap = CreateFrame("Button", "vQC_MiniMap", Minimap)
		vQC_MiniMap:SetFrameLevel(8)
		vQC_MiniMap:SetSize(28, 28)
		vQC_MiniMap:SetNormalTexture("Interface\\TARGETINGFRAME\\PortraitQuestBadge")
		vQC_MiniMap:ClearAllPoints()
		vQC_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 5, -20)
		vQC_MiniMap:SetMovable(false)
			vQC_MiniMap:SetScript("OnClick", function() WatchQLogAct(0) end)
			vQC_MiniMap:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniMap) end)
			vQC_MiniMap:SetScript("OnLeave", function() ToolTipsOnly(0) end)
------------------------------------------------------------------------
-- Mini Frame for Quest Log/World Frame
------------------------------------------------------------------------
	local vQC_MiniQ = CreateFrame("Frame", "vQC_MiniQ", QuestFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_MiniQ:SetBackdrop(Backdrop_A)
		vQC_MiniQ:SetSize(95,26)
		vQC_MiniQ:ClearAllPoints()
		vQC_MiniQ:SetPoint("TOPRIGHT", QuestFrame, -3, -23)
			vQC_MiniQ.Text = vQC_MiniQ:CreateFontString("T")
			vQC_MiniQ.Text:SetFont(FontStyle[1], Font_Md, "OUTLINE")
			vQC_MiniQ.Text:SetPoint("LEFT", vQC_MiniQ, 10, 0)
			vQC_MiniQ.Text:SetText("")
			local vQC_QFIcon = CreateFrame("Button", "vQC_QFIcon", vQC_MiniQ)
				vQC_QFIcon:SetSize(16,16)
				vQC_QFIcon:SetNormalTexture("Interface\\GossipFrame\\AvailableQuestIcon")
				vQC_QFIcon:SetPoint("RIGHT", vQC_MiniQ, -5, 0)
				vQC_QFIcon:SetScript("OnClick", function() WatchQLogAct(1) end)
				vQC_QFIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniQ) end)
				vQC_QFIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
		vQC_MiniQ:Hide()
	local vQC_MiniW = CreateFrame("Frame", "vQC_MiniW", QuestMapFrame.DetailsFrame, BackdropTemplateMixin and "BackdropTemplate")
		vQC_MiniW:SetBackdrop(Backdrop_A)
		vQC_MiniW:SetSize(95,26)
		vQC_MiniW:ClearAllPoints()
		vQC_MiniW:SetPoint("TOPRIGHT", QuestMapFrame.DetailsFrame, 27, 45)
			vQC_MiniW.Text = vQC_MiniW:CreateFontString("T")
			vQC_MiniW.Text:SetFont(FontStyle[1], Font_Md, "OUTLINE")
			vQC_MiniW.Text:SetPoint("LEFT", vQC_MiniW, 10, 0)
			vQC_MiniW.Text:SetText("")
			local vQC_WFIcon = CreateFrame("Button", "vQC_WFIcon", vQC_MiniW)
				vQC_WFIcon:SetSize(16,16)
				vQC_WFIcon:SetNormalTexture("Interface\\GossipFrame\\AvailableQuestIcon")
				vQC_WFIcon:SetPoint("RIGHT", vQC_MiniW, -5, 0)
				vQC_WFIcon:SetScript("OnClick", function() WatchQLogAct(1) end)
				vQC_WFIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MiniW) end)
				vQC_WFIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
		vQC_MiniW:Hide()
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
		vQC_Main:Hide()
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
			vQC_Title.Text:SetFont(FontStyle[1], Font_Lg, "OUTLINE")
			vQC_Title.Text:SetPoint("CENTER", vQC_Title)
			vQC_Title.Text:SetText(vQC_AppTitle)
			local vQC_TitleX = CreateFrame("Button", "vQC_TitleX", vQC_Title, "UIPanelCloseButton")
				vQC_TitleX:SetSize(20, 20)
				vQC_TitleX:SetPoint("TOPRIGHT", vQC_Title, -2, -2)
				vQC_TitleX:SetScript("OnClick", function() vQC_Main:Hide() end)
-- Main Quest Input
	local vQC_Quest = CreateFrame("Frame", "vQC_Quest", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		--vQC_Quest:SetBackdrop(Backdrop_B)
		vQC_Quest:SetSize(vQC_Main:GetWidth()-5,26)
		vQC_Quest:ClearAllPoints()
		vQC_Quest:SetPoint("TOP", vQC_Title, 0, 0-vQC_Title:GetHeight()+1)
		local vQC_Quest_MemIcon = CreateFrame("Button", "vQC_Quest_MemIcon", vQC_Quest)
			vQC_Quest_MemIcon:SetSize(16,16)
			vQC_Quest_MemIcon:SetPoint("TOPLEFT", vQC_Quest, 2, -1)
			vQC_Quest_MemIcon:SetNormalTexture("Interface\\COMMON\\Indicator-Green")
			vQC_Quest_MemIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_Quest_MemIcon) end)
			vQC_Quest_MemIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
			vQC_Quest_MemIcon:Hide()
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
		vQC_ResultHeader:SetSize(vQC_Main:GetWidth()-5,24)
		vQC_ResultHeader:ClearAllPoints()
		vQC_ResultHeader:SetPoint("TOP", vQC_Quest, 0, 0-vQC_Quest:GetHeight()+1)
			vQC_ResultHeader.Text = vQC_ResultHeader:CreateFontString("T")
			vQC_ResultHeader.Text:SetFont(FontStyle[1], Font_Lg, "OUTLINE")
			vQC_ResultHeader.Text:SetPoint("CENTER", vQC_ResultHeader, "CENTER", 0, 0)
			vQC_ResultHeader.Text:SetText("")
-- Main Quest Results (Not Found)
	local vQC_NoResultsFound = CreateFrame("Frame", "vQC_NoResultsFound", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_NoResultsFound:SetSize(vQC_Main:GetWidth()-5,vQC_Main:GetHeight()-(vQC_Title:GetHeight()+vQC_ResultHeader:GetHeight()+vQC_Quest:GetHeight()-4))
		vQC_NoResultsFound:ClearAllPoints()
		vQC_NoResultsFound:SetPoint("TOP", vQC_ResultHeader, 0, 0-vQC_ResultHeader:GetHeight()+3)
			vQC_NoResultsFound.Text = vQC_NoResultsFound:CreateFontString("T")
			vQC_NoResultsFound.Text:SetFont(FontStyle[1], Font_Md, "OUTLINE")
			vQC_NoResultsFound.Text:SetPoint("TOP", vQC_NoResultsFound, 0, 0)
			vQC_NoResultsFound.Text:SetText(
				"|TInterface\\HELPFRAME\\HelpIcon-ReportAbuse:28|t|TInterface\\Store\\category-icon-placeholder:42|t"..
				"|TInterface\\PVPFrame\\PVPCurrency-Honor-Alliance:36|t|TInterface\\PVPFrame\\PVPCurrency-Honor-Horde:36|t"..
				"|TInterface\\HELPFRAME\\HelpIcon-CharacterStuck:32|t\n"..
				"Never Existed/Removed,\nRare/Hidden Trigger,\nOpposite Faction,\n"..Colors(2,"OR").."\nSlow API Request"
			)
			vQC_NoResultsFound:Hide()
-- Main Quest Results (Found)
	local vQC_YesResultsFound = CreateFrame("Frame", "vQC_YesResultsFound", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_YesResultsFound:SetSize(vQC_Main:GetWidth()-5,vQC_Main:GetHeight()-(vQC_Title:GetHeight()+vQC_ResultHeader:GetHeight()+vQC_Quest:GetHeight()-4))
		vQC_YesResultsFound:ClearAllPoints()
		vQC_YesResultsFound:SetPoint("TOP", vQC_ResultHeader, 0, 0-vQC_ResultHeader:GetHeight())
			vQC_YesResultsFound.Text = vQC_YesResultsFound:CreateFontString("T") -- Quest Completed or Not
			vQC_YesResultsFound.Text:SetFont(FontStyle[1], Font_Lg, "OUTLINE")
			vQC_YesResultsFound.Text:SetPoint("TOP", vQC_YesResultsFound, 0, -8)
			vQC_YesResultsFound.Text:SetText("")
			vQC_YesResultsFound:Hide()
-- Main Quest Results Layout
-- Quest ID
	local vQC_L_ID = CreateFrame("Frame", "vQC_L_ID", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_ID:SetSize(tRWi,20)
		vQC_L_ID:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0)
			vQC_L_ID.Text = vQC_L_ID:CreateFontString("T")
			vQC_L_ID.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_ID.Text:SetPoint("RIGHT", vQC_L_ID)
			vQC_L_ID.Text:SetText(Colors(4,"ID:"))
	local vQC_T_ID = CreateFrame("Frame", "vQC_T_ID", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_ID:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_ID:GetWidth(),20)
		vQC_T_ID:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0)
			vQC_T_ID.Text = vQC_T_ID:CreateFontString("T")
			vQC_T_ID.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_ID.Text:SetPoint("LEFT", vQC_T_ID)
			vQC_T_ID.Text:SetText("---")
-- Quest Name
	local vQC_L_Na = CreateFrame("Frame", "vQC_L_Na", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_Na:SetSize(tRWi,20)
		vQC_L_Na:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*2)
			vQC_L_Na.Text = vQC_L_Na:CreateFontString("T")
			vQC_L_Na.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_Na.Text:SetPoint("RIGHT", vQC_L_Na)
			vQC_L_Na.Text:SetText(Colors(4,"Name:"))
	local vQC_T_Na = CreateFrame("Frame", "vQC_T_Na", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_Na:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_Na:GetWidth(),20)
		vQC_T_Na:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*2)
			vQC_T_Na.Text = vQC_T_Na:CreateFontString("T")
			vQC_T_Na.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_Na.Text:SetPoint("LEFT", vQC_T_Na)
			vQC_T_Na.Text:SetText("---")
-- Quest Level
	local vQC_L_Lv = CreateFrame("Frame", "vQC_L_Lv", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_Lv:SetSize(tRWi,20)
		vQC_L_Lv:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*4)
			vQC_L_Lv.Text = vQC_L_Lv:CreateFontString("T")
			vQC_L_Lv.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_Lv.Text:SetPoint("RIGHT", vQC_L_Lv)
			vQC_L_Lv.Text:SetText(Colors(4,"Level:"))
	local vQCB_T_Lv = CreateFrame("Frame", "vQCB_T_Lv", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQCB_T_Lv:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_Lv:GetWidth(),20)
		vQCB_T_Lv:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*4)
			vQCB_T_Lv.Text = vQCB_T_Lv:CreateFontString("T")
			vQCB_T_Lv.Text:SetFont(FontStyle[1], Font_Sm)
			vQCB_T_Lv.Text:SetPoint("LEFT", vQCB_T_Lv)
			vQCB_T_Lv.Text:SetText("---")
-- Quest XY Coord
	local vQC_L_XY = CreateFrame("Frame", "vQC_L_XY", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_XY:SetSize(tRWi,20)
		vQC_L_XY:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*6)
			vQC_L_XY.Text = vQC_L_XY:CreateFontString("T")
			vQC_L_XY.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_XY.Text:SetPoint("RIGHT", vQC_L_XY)
			vQC_L_XY.Text:SetText(Colors(4,"Coord:"))
	local vQC_T_XY = CreateFrame("Frame", "vQC_T_XY", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_XY:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_XY:GetWidth(),20)
		vQC_T_XY:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*6)
			vQC_T_XY.Text = vQC_T_XY:CreateFontString("T")
			vQC_T_XY.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_XY.Text:SetPoint("LEFT", vQC_T_XY)
			vQC_T_XY.Text:SetText("---")
-- Quest Subzone
	local vQC_L_SZ = CreateFrame("Frame", "vQC_L_SZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_SZ:SetSize(tRWi,20)
		vQC_L_SZ:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*8)
			vQC_L_SZ.Text = vQC_L_SZ:CreateFontString("T")
			vQC_L_SZ.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_SZ.Text:SetPoint("RIGHT", vQC_L_SZ)
			vQC_L_SZ.Text:SetText(Colors(4,"Subzone:"))
	local vQC_T_SZ = CreateFrame("Frame", "vQC_T_SZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_SZ:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_SZ:GetWidth(),20)
		vQC_T_SZ:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*8)
			vQC_T_SZ.Text = vQC_T_SZ:CreateFontString("T")
			vQC_T_SZ.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_SZ.Text:SetPoint("LEFT", vQC_T_SZ)
			vQC_T_SZ.Text:SetText("---")
-- Quest Zone
	local vQC_L_MZ = CreateFrame("Frame", "vQC_L_MZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_MZ:SetSize(tRWi,20)
		vQC_L_MZ:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*10)
			vQC_L_MZ.Text = vQC_L_MZ:CreateFontString("T")
			vQC_L_MZ.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_MZ.Text:SetPoint("RIGHT", vQC_L_MZ)
			vQC_L_MZ.Text:SetText(Colors(4,"Zone:"))
	local vQC_T_MZ = CreateFrame("Frame", "vQC_T_MZ", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_MZ:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_MZ:GetWidth(),20)
		vQC_T_MZ:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*10)
			vQC_T_MZ.Text = vQC_T_MZ:CreateFontString("T")
			vQC_T_MZ.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_MZ.Text:SetPoint("LEFT", vQC_T_MZ)
			vQC_T_MZ.Text:SetText("---")
-- Quest Storyline
	local vQC_L_St = CreateFrame("Frame", "vQC_L_St", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_L_St:SetSize(tRWi,20)
		vQC_L_St:SetPoint("TOPLEFT", vQC_YesResultsFound, 0, 0-tHei*12)
			vQC_L_St.Text = vQC_L_St:CreateFontString("T")
			vQC_L_St.Text:SetFont(FontStyle[1], Font_Sm, "OUTLINE")
			vQC_L_St.Text:SetPoint("RIGHT", vQC_L_St)
			vQC_L_St.Text:SetText(Colors(4,"Storyline:"))
	local vQC_T_St = CreateFrame("Frame", "vQC_T_St", vQC_YesResultsFound, BackdropTemplateMixin and "BackdropTemplate")
		vQC_T_St:SetSize(vQC_YesResultsFound:GetWidth()-vQC_L_St:GetWidth(),20)
		vQC_T_St:SetPoint("TOPRIGHT", vQC_YesResultsFound, 0, 0-tHei*12)
			vQC_T_St.Text = vQC_T_St:CreateFontString("T")
			vQC_T_St.Text:SetFont(FontStyle[1], Font_Sm)
			vQC_T_St.Text:SetPoint("LEFT", vQC_T_St)
			vQC_T_St.Text:SetText("---")
------------------------------------------------------------------------
-- Storyline Window
------------------------------------------------------------------------
-- Storyline Main
	local vQC_StoryMain = CreateFrame("Frame", "vQC_StoryMain", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_StoryMain:SetBackdrop(Backdrop_A)
		vQC_StoryMain:SetSize(vQC_Main:GetWidth(),128)
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
			vQC_StoryTitle.Text:SetFont(FontStyle[1], Font_Lg, "OUTLINE")
			vQC_StoryTitle.Text:SetPoint("CENTER", vQC_StoryTitle, "CENTER",0, 0)
			vQC_StoryTitle.Text:SetText(Colors(4,"---"))
-- Storyline Results
	local vQC_SLResult = CreateFrame("Frame", "vQC_SLResult", vQC_StoryMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_SLResult:SetSize(vQC_StoryMain:GetWidth()-2,vQC_StoryMain:GetHeight()-vQC_StoryTitle:GetHeight()-2)
		vQC_SLResult:ClearAllPoints()
		vQC_SLResult:SetPoint("TOP", vQC_StoryTitle, 0, 0-vQC_StoryTitle:GetHeight()+3)
		local vQC_SLResultScFr = CreateFrame("ScrollFrame", "vQC_SLResultScFr", vQC_SLResult, "UIPanelScrollFrameTemplate")
			vQC_SLResultScFr:ClearAllPoints()
			vQC_SLResultScFr:SetSize(vQC_SLResult:GetWidth()-33,vQC_SLResult:GetHeight()-11)
			vQC_SLResultScFr:SetPoint("TOPLEFT", vQC_SLResult, 5, -6)
			vQC_SLResult.vQC_SLResultScFr = vQC_SLResultScFr
		local vQC_SLContent = CreateFrame("Frame", "vQC_SLContent", vQC_SLResultScFr, BackdropTemplateMixin and "BackdropTemplate")
			vQC_SLContent:SetSize(1,1)
			vQC_SLContent.Content = vQC_SLContent
			vQC_SLResultScFr:SetScrollChild(vQC_SLContent)
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
			vQC_ATTMain:SetPoint("TOPRIGHT", vQC_Main, vQC_ATTMain:GetWidth()-3, 0)
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
			vQC_ATTTitle.Text:SetFont(FontStyle[1], Font_Md, "OUTLINE")
			vQC_ATTTitle.Text:SetPoint("CENTER", vQC_ATTTitle, 0, 1)
			vQC_ATTTitle.Text:SetText(Colors(7,"Completed By"))
-- ATT Icon
	local vQC_ATTIconBG = CreateFrame("Frame", "vQC_ATTIconBG", vQC_ATTTitle, BackdropTemplateMixin and "BackdropTemplate")
		vQC_ATTIconBG:SetBackdrop(Backdrop_NBdr)
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
				vQC_ATTArea:SetWidth(200)
				--vQC_ATTArea:SetFont(FontStyle[1], Font_Sm, "OUTLINE,MONOCHROME")
				vQC_ATTArea:SetFontObject(GameFontNormalSmall)
				vQC_ATTArea:SetAutoFocus(false)
				vQC_ATTArea:SetMultiLine(true)
				vQC_ATTArea:EnableMouse(false)
			vQC_ATTRScr:SetScrollChild(vQC_ATTArea)
------------------------------------------------------------------------
-- For World Boss Window
------------------------------------------------------------------------	
	-- WorldBoss Frame
	local vQC_WBMain = CreateFrame("Frame", "vQC_WBMain", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vQC_WBMain:SetBackdrop(Backdrop_A)
		vQC_WBMain:SetSize(354,100)
		vQC_WBMain:ClearAllPoints()
		vQC_WBMain:SetPoint("CENTER", UIParent, 0, 0)
		vQC_WBMain:EnableMouse(true)
		vQC_WBMain:SetMovable(true)
		vQC_WBMain:RegisterForDrag("LeftButton")
		vQC_WBMain:SetScript("OnDragStart", function() vQC_WBMain:StartMoving() end)
		vQC_WBMain:SetScript("OnDragStop", function() vQC_WBMain:StopMovingOrSizing() end)
		vQC_WBMain:Hide()
	-- World Boss Title Frame
	local vQC_WBTitle = CreateFrame("Frame", "vQC_WBTitle", vQC_WBMain, BackdropTemplateMixin and "BackdropTemplate")
		vQC_WBTitle:SetBackdrop(Backdrop_B)
		vQC_WBTitle:SetSize(vQC_WBMain:GetWidth()-6,24)
		vQC_WBTitle:ClearAllPoints()
		vQC_WBTitle:SetPoint("TOP", vQC_WBMain, 0, -3)
			vQC_WBTitle.Icon = vQC_WBTitle:CreateTexture(nil, "OVERLAY")
			vQC_WBTitle.Icon:SetSize(128,64)
			vQC_WBTitle.Icon:SetPoint("TOPLEFT", vQC_WBTitle, 0, 43)
			vQC_WBTitle.Icon:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-"..WorldBossList[math.random(#WorldBossList)][5])
			vQC_WBTitle.Text = vQC_WBTitle:CreateFontString("T")
			vQC_WBTitle.Text:SetFont(FontStyle[1], Font_Lg, "OUTLINE")
			vQC_WBTitle.Text:SetPoint("CENTER", vQC_WBTitle, 0, 0)
			vQC_WBTitle.Text:SetText(Colors(7,"World Boss(es)"))
			local vQC_WBMainT = CreateFrame("Button", "vQC_TitleX", vQC_WBTitle, "UIPanelCloseButton")
				vQC_WBMainT:SetSize(26,26)
				vQC_WBMainT:SetPoint("RIGHT", vQC_WBTitle, 0, 0)
				vQC_WBMainT:SetScript("OnClick", function() vQC_WBMain:Hide() end)
			local vQC_WBMainRefresh = CreateFrame("Button", "vQC_WBMainRefresh", vQC_WBTitle)
				vQC_WBMainRefresh:SetSize(24, 24)
				vQC_WBMainRefresh:SetNormalTexture("Interface\\GLUES\\CharacterSelect\\CharacterUndelete")
				vQC_WBMainRefresh:ClearAllPoints()
				vQC_WBMainRefresh:SetPoint("RIGHT", vQC_WBTitle.Text, 25, 0)
				vQC_WBMainRefresh:SetScript("OnClick", function() WorldBossCheck() end)
				vQC_WBMainRefresh:SetScript("OnEnter", function() ToolTipsOnly(vQC_WBMainRefresh) end)
				vQC_WBMainRefresh:SetScript("OnLeave", function() ToolTipsOnly(0) end)

------------------------------------------------------------------------
-- Icon for Map Pin if X,Y Exist
------------------------------------------------------------------------
	local vQC_MapPinIcon = CreateFrame("Button", "vQC_MapPinIcon", vQC_T_XY)
		vQC_MapPinIcon:SetSize(24, 24)
		vQC_MapPinIcon:SetNormalTexture("Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked")
		vQC_MapPinIcon:ClearAllPoints()
		vQC_MapPinIcon:SetPoint("RIGHT", vQC_T_XY, -8, 0)
		vQC_MapPinIcon:SetScript("OnClick", function() MakePins(vQC_QuestID:GetNumber(),0,0,0) end)
		vQC_MapPinIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_MapPinIcon) end)
		vQC_MapPinIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)
		vQC_MapPinIcon:Hide()
------------------------------------------------------------------------
-- Icon for QuestID Open ATT Windows
------------------------------------------------------------------------
	local vQC_ATTPin = CreateFrame("Button", "vQC_ATTPin", vQC_T_ID)
		vQC_ATTPin:SetSize(24, 24)
		vQC_ATTPin:SetNormalTexture("Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked")
		vQC_ATTPin:ClearAllPoints()
		vQC_ATTPin:SetPoint("RIGHT", vQC_T_ID, -8, 0)
		vQC_ATTPin:SetScript("OnClick", function() SlashCmdList["AllTheThings"]("questid:"..vQC_T_ID.Text:GetText()) end)
		vQC_ATTPin:SetScript("OnEnter", function() ToolTipsOnly(vQC_ATTPin) end)
		vQC_ATTPin:SetScript("OnLeave", function() ToolTipsOnly(0) end)
		vQC_ATTPin:Hide()
------------------------------------------------------------------------
-- For WOWHead Icon/Link Frame
------------------------------------------------------------------------			
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
	local vQC_Query_Anim = CreateFrame("Frame", "vQC_Query_Anim", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_Query_Anim:SetBackdropColor(1,0,1,0)
		vQC_Query_Anim:SetPoint("BOTTOMRIGHT", vQC_Main, 3, -2)
		vQC_Query_Anim:SetSize(58,58)
			vQC_Query_Anim.Text = vQC_Query_Anim:CreateFontString("T")
			vQC_Query_Anim.Text:SetFont(FontStyle[1], Font_Md, "OUTLINE")
			vQC_Query_Anim.Text:SetPoint("CENTER", vQC_Query_Anim, "CENTER", 1, 0)
			vQC_Query_Anim.Text:SetText(Colors(7,"API"))
		vQC_Query_Anim.Bkgnd = vQC_Query_Anim:CreateTexture(nil, "BACKGROUND")
		vQC_Query_Anim.Bkgnd:SetTexture("Interface\\UNITPOWERBARALT\\Arcane_Circular_Frame")
		vQC_Query_Anim.Bkgnd:SetAllPoints(vQC_Query_Anim)
			vQC_Query_Anim.AG = vQC_Query_Anim.Bkgnd:CreateAnimationGroup()
				vQC_Query_Anim.AG:SetLooping("REPEAT")
			vQC_Query_Anim.CA = vQC_Query_Anim.AG:CreateAnimation("Rotation")
				vQC_Query_Anim.CA:SetDuration(5)
				vQC_Query_Anim.CA:SetDegrees(360)
		vQC_Query_Anim:Hide()
------------------------------------------------------------------------
-- Side "Tabs"
------------------------------------------------------------------------		
	local vQC_SideTab = CreateFrame("Frame", "vQC_SideTab", vQC_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQC_SideTab:SetBackdrop(Backdrop_B)
		vQC_SideTab:ClearAllPoints()
		vQC_SideTab:SetSize(35,vQC_Main:GetHeight())
		vQC_SideTab:SetPoint("LEFT", vQC_Main, -32, 0)
		vQC_SideTab:SetScript("OnDragStart", function() vQC_Main:StartMoving() end)
		vQC_SideTab:SetScript("OnDragStop", function() vQC_Main:StopMovingOrSizing() end)

		-- World Icon
		local vQC_WhereIcon = CreateFrame("Button", "vQC_WhereIcon", vQC_SideTab)
			vQC_WhereIcon:SetSize(22, 22)
			vQC_WhereIcon:SetPoint("TOPLEFT", vQC_SideTab, 7, -8)
			vQC_WhereIcon:SetNormalTexture("Interface\\Worldmap\\UI-World-Icon")
			vQC_WhereIcon:SetScript("OnClick", function() WhereAmI() end)
			vQC_WhereIcon:SetScript("OnEnter", function() ToolTipsOnly(vQC_WhereIcon) end)
			vQC_WhereIcon:SetScript("OnLeave", function() ToolTipsOnly(0) end)

		-- WoWHEAD Icon
		local vQC_WHLinkIcon = CreateFrame("Button", "vQC_WHLinkIcon", vQC_SideTab)
			vQC_WHLinkIcon:SetSize(26,28)
			vQC_WHLinkIcon:SetPoint("TOPLEFT", vQC_SideTab, 5, -33)
			vQC_WHLinkIcon:SetNormalTexture("Interface\\Addons\\QuestChecker\\Images\\ATTImages")
			vQC_WHLinkIcon:GetNormalTexture():SetTexCoord(0.75, 0, 0.75, 1, 0.875, 0, 0.875, 1)
			vQC_WHLinkIcon:SetScript("OnClick", function() WHLink() end)
			
		-- World Boss Icon
		local vQC_MainWBIcon = CreateFrame("Button", "vQC_MainWBIcon", vQC_SideTab)
			vQC_MainWBIcon:SetSize(36,36)
			vQC_MainWBIcon:SetPoint("TOPLEFT", vQC_SideTab, 0, -60)
			vQC_MainWBIcon:SetNormalTexture("Interface\\ENCOUNTERJOURNAL\\UI-EncounterJournalTextures")
			vQC_MainWBIcon:GetNormalTexture():SetTexCoord(0.898, 0.269, 0.898, 0.322, 1, 0.269, 1, 0.322)
			vQC_MainWBIcon:SetScript("OnClick", function() WorldBossCheck(1) end)
			
		-- NPC Info Icon
		local vQC_MainNPCIcon = CreateFrame("Button", "vQC_MainNPCIcon", vQC_SideTab)
			vQC_MainNPCIcon:SetSize(33,33)
			vQC_MainNPCIcon:SetPoint("TOPLEFT", vQC_SideTab, 1, -85)
			vQC_MainNPCIcon:SetNormalTexture("Interface\\COMMON\\help-i")
			vQC_MainNPCIcon:SetScript("OnClick", function() WhoIsThis() end)

		-- Debug Icon
		local vQC_DebugIcon = CreateFrame("Button", "vQC_DebugIcon", vQC_SideTab)
			vQC_DebugIcon:SetSize(30, 30)
			vQC_DebugIcon:SetPoint("TOPLEFT", vQC_SideTab, 2, -153)
			vQC_DebugIcon:SetNormalTexture("Interface\\GLUES\\CharacterSelect\\CharacterUndelete")
			vQC_DebugIcon:SetScript("OnClick", function()
				vQC_QuestID:SetNumber(math.random(MaxQuestID))
				CheckQuestAPI()
			end)
			if DEBUG then vQC_DebugIcon:Show() else vQC_DebugIcon:Hide() end

------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
local vQC_OnUpdate = CreateFrame("Frame")
vQC_OnUpdate:RegisterEvent("ADDON_LOADED")
vQC_OnUpdate:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local TheEvents = {
			-- All To Do With Quest
			"QUEST_DETAIL",				-- Checks when Quest Being Looked At/Ready To Accept/Decline
			"QUEST_FINISHED",			-- Checks when Quest Turned in/Finished
			"QUEST_LOG_UPDATE",			-- Checks ANY Quest that is actively searching
			"QUEST_PROGRESS",			-- Checks when Quest are in Progress
			"QUEST_TURNED_IN",			-- Checks when Quest Turned in/Finished
			"QUEST_COMPLETE",			-- Checks when Quest Turned in/Finished
			"PLAYER_MONEY",				-- Listen for Anima Amount Changes
			"CURRENCY_DISPLAY_UPDATE",	-- Currency Updater
			"BAG_UPDATE",				-- Fire when there new Anima in the BAG
		}
		for ev = 1, #TheEvents do
			vQC_OnUpdate:RegisterEvent(TheEvents[ev])
		end
		vQC_OnUpdate:UnregisterEvent("ADDON_LOADED")
		vQC_OnUpdate:RegisterEvent("PLAYER_LOGIN")
	end
	if event == "PLAYER_LOGIN" then
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vQC_AppTitle..(DEBUG and Colors(1,"  [Debug Mode]") or ""))
		
		SLASH_QuestChecker1 = '/qc'
		SLASH_QuestChecker2 = '/qcheck'
		SLASH_QuestChecker3 = '/qchecker'
		SlashCmdList["QuestChecker"] = function(cmd)
		
			if string.match(cmd,"%d") then
				if not vQC_Main:IsVisible() then vQC_Main:Show() end
				WatchQLogAct()
				vQC_QuestID:SetNumber(cmd)
				CheckQuestAPI()
			else
				local cmd = string.lower(cmd)
			
				if not cmd or cmd == "" then
					WatchQLogAct(0)
				elseif cmd == "debug" or cmd == "d" then
					if DEBUG then
						DEBUG = false
						vQC_DebugIcon:Hide()
					else
						DEBUG = true
						vQC_DebugIcon:Show()
					end
					print("Debug "..(DEBUG and "en" or "dis").."abled")
				elseif cmd == "ver" or cmd == "v" then
					print(vQC_AppTitle.." - "..vQC_Revision)
				elseif cmd == "worldboss" or cmd == "wb" then
					WorldBossCheck(1)
				elseif cmd == "?" then
					print(Colors(4,"Command To Use:"))
					print(Colors(2,"attcheck or a")..Colors(4," - Check Toons/Quest"))
					print(Colors(2,"debug or d")..Colors(4," - Enable Debugging"))
					print(Colors(2,"ver or v")..Colors(4," - Show QC Version/Revision"))
					print(Colors(2,"worldboss or wb")..Colors(4," - Check World Boss"))
					print(Colors(2,"#")..Colors(4," - Put in ## to Pull Quest ID"))
				else
					print("What?  Not sure what you're asking... Try again!")
				end	
			end
		end
		
		if IsAddOnLoaded("AllTheThings") then  vQC_ATTMain:Show() else vQC_ATTMain:Hide() end
		
		vQC_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
	end
	if event == "QUEST_DETAIL" or
		event == "QUEST_FINISHED" or
		event == "QUEST_LOG_UPDATE" or
		event == "QUEST_PROGRESS" or
		event == "QUEST_TURNED_IN" or
		event == "QUEST_COMPLETE" then
			if vQC_WBMain:IsVisible() then Status = xpcall(WorldBossCheck(),err) end -- if World Boss Window is open, update it
			if vQC_Main:IsVisible() or QuestFrame:IsVisible() or QuestMapFrame.DetailsFrame:IsVisible() then
				Status = xpcall(WatchQLogAct(),err)
			end
	end
	if event == "QUEST_FINISHED" or event == "QUEST_COMPLETE" then
		Status = xpcall(WatchMemoryCount(), err) --Clean up Before Storyline Query
	end	

	if DEBUG then DeOutput("Event: "..event) end
end)