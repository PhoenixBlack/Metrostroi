include("shared.lua")


--------------------------------------------------------------------------------
ENT.ClientProps = {}
ENT.ButtonMap = {}


-- Main panel
ENT.ButtonMap["Main"] = {
	pos = Vector(446.2,14.0,-0.5),
	ang = Angle(0,-90,44),
	width = 460,
	height = 230,
	scale = 0.0625,
	
	buttons = {		
		{ID = "KVTSet",			x=247, y=33, radius=20, tooltip=""},
		{ID = "PS8",			x=295, y=33, radius=20, tooltip=""},
		
		{ID = "VUD1Toggle",		x=54, y=105, radius=40, tooltip="ВУД: Выключатель управления дверьми\nVUD: Door control toggle (close doors)"},
		{ID = "KDLSet",			x=50, y=180, radius=20, tooltip="КДЛ: Кнопка левых дверей\nKDL: Left doors open"},
		{ID = "VDLSet",			x=153, y=180, radius=20, tooltip="ВДЛ: Выключатель левых дверей\nVDL: Left doors open"},
		{ID = "DoorSelectToggle",x=105, y=183, radius=20, tooltip="Выбор стороны открытия дверей\nSelect side on which doors will open"},
		{ID = "KRZDSet",		x=153, y=83, radius=20, tooltip="КРЗД: Кнопка резервного закрытия дверей\nKRZD: Emergency door closing"},
		{ID = "VozvratRPSet",	x=105, y=132, radius=20, tooltip="Возврат реле перегрузки\nReset overload relay"},
		
		{ID = "GreenRPLight",	x=153, y=135, radius=20, tooltip="РП: Зелёная лампа реле перегрузки\nRP: Green overload relay light (overload relay open on current train)"},
		{ID = "AVULight",		x=325, y=92, radius=20, tooltip="АВУ: Автоматический выключатель управления\nAVU: Automatic control disabler active"},
		{ID = "KVPLight",		x=370, y=92, radius=20, tooltip="КВП: Контроль высоковольного преобразователя\nKVP: High-voltage converter control"},
		{ID = "SPLight",		x=411, y=30, radius=20, tooltip="(placeholder) LSP"},
		{ID = "PS20",			x=247, y=84, radius=20, tooltip="(placeholder) VN"},
		{ID = "PS21",			x=295, y=84, radius=20, tooltip="(placeholder) DAU ARS"},
		
		{ID = "PS6",			x=330, y=130, radius=20, tooltip="(placeholder) Converter protection"},
		{ID = "KSNSet",			x=370, y=130, radius=20, tooltip="КСН: Кнопка сигнализации неисправности\nKSN: Failure indication button"},
		{ID = "DIPoffSet",		x=420, y=130, radius=20, tooltip="Звонок\nRing"},
		
		{ID = "ARSToggle",		x=238, y=135, radius=20, tooltip="АРС: Включение системы автоматического регулирования скорости\nARS: Automatic speed regulation"},
		{ID = "ALSToggle",		x=267, y=135, radius=20, tooltip="АЛС: Включение системы автоматической локомотивной сигнализации\nALS: Automatic locomotive signalling"},
		
		{ID = "OtklAVUToggle",	x=283, y=183, radius=20, tooltip="Отключение автоматического выключения управления (неисправность реле АВУ)\nTurn off automatic control disable relay (failure of AVU relay)"},		
		{ID = "PS2",			x=238, y=183, radius=20, tooltip="(placeholder) Emergency brake toggle"},
		{ID = "L_1Toggle",		x=320, y=183, radius=20, tooltip="Освещение салона\nWagon lighting"},
		{ID = "L_2Toggle",		x=355, y=183, radius=20, tooltip="Освещение кабины\nCabin lighting"},
		{ID = "L_3Toggle",		x=395, y=183, radius=20, tooltip="Освещение пульта\nPanel lighting"},
	}
}

-- Front panel
ENT.ButtonMap["Front"] = {
	pos = Vector(444.2,-15.5,1.8),
	ang = Angle(0,-90,56.5),
	width = 220,
	height = 250,
	scale = 0.0625,
	
	buttons = {
		{ID = "VUSToggle",x=90, y=200, radius=20, tooltip="ВУС: Выключатель усиленого света ходовых фар\nVUS: Head lights bright/dim"},
		{ID = "VAHToggle",x=170, y=200, radius=20, tooltip="ВАХ: Включение аварийного хода (неисправность реле педали безопасности)\nVAH: Emergency driving mode (failure of RPB relay)"},
		{ID = "VADToggle",x=127, y=200, radius=20, tooltip="ВАД: Включение аварийного закрытия дверей (неисправность реле контроля дверей)\nVAD: Emergency door close override (failure of KD relay)"},		
		{ID = "RezMKSet",x=53,  y=98, radius=20, tooltip="Резервное включение мотор-компрессора\nEmergency motor-compressor startup"},
		{ID = "KRPSet",x=53, y=33, radius=20, tooltip="КРП: Кнопка резервного пуска"},
		
		{ID = "L_4Toggle",x=53, y=200, radius=20, tooltip="Выключатель фар\nHeadlights toggle"},
		{ID = "CabinHeatLight",x=90, y=145, radius=20, tooltip="Контроль печи\nCabin heater active"},
		{ID = "KDPSet",x=130, y=145, radius=32, tooltip="КДП: Кнопка правых дверей\nKDP: Right doors open"},
		
		{ID = "PneumoLight",x=170, y=145, radius=20, tooltip="Контроль пневмотормоза\nPneumatic brake control"},
	}
}

-- BPSN panel
ENT.ButtonMap["BPSNFront"] = {
	pos = Vector(448.2,31.0,8.0),
	ang = Angle(0,-90,56.5),
	width = 310,
	height = 120,
	scale = 0.0625,
	
	buttons = {
		{x=245,y=60,tooltip="Напряжение цепей управления\nControl circuits voltage",radius=60},
		{ID = "VMKToggle",x=43,  y=28, radius=20, tooltip="Включение мотор-компрессора\nTurn motor-compressor on"},
		{ID = "BPSNonToggle",x=83,  y=28, radius=20, tooltip="БПСН: Блок питания собственных нужд\nBPSN: Train power supply"},
		{ID = "L_5Toggle",x=126, y=28, radius=20, tooltip="Аварийное освещение\nEmergency lighting"},
		
		{ID = "PS9", x=83, y=80, radius=20, tooltip="(placeholder) Radio 13V"},
		{ID = "PS10",x=126, y=80, radius=20, tooltip="(placeholder) ARS 13V"},
	}
}

-- ARS/Speedometer panel
ENT.ButtonMap["ARS"] = {
	pos = Vector(448.28,11.0,7.82),
	ang = Angle(0,-90-0.2,56.3),
	width = 300*10,
	height = 110*10,
	scale = 0.0625/10,

	buttons = {
		{x=1100+70,y=160+70,tooltip="Индикатор скорости\nSpeed indicator",radius=130},
		{x=1780+60,y=780+60,tooltip="ЛСН: Лампа сигнализации неисправности\nLSN: Failure indicator light (power circuits failed to assemble)",radius=120},
		{x=1520+60,y=780+60,tooltip="РП: Красная лампа реле перегрузки\nRP: Red overload relay light (power circuits failed to assemble)",radius=120},
		{x=1110+60,y=780+60,tooltip="ЛхРК: Лампа хода реостатного контроллера\nLhRK: Rheostat controller motion light",radius=120},
		{x=2130+60,y=780+60,tooltip="ЛКТ: Контроль тормоза\nLKT: ARS braking indicator",radius=120},
		{x=2130+60,y=550+60,tooltip="ЛКВД: Контроль выключения двигателей\nLKVD: ARS engine shutdown indicator",radius=120},
		{x=2540+60,y=100+60,tooltip="ЛКВЦ: Лампа контактора высоковольтных цепей\nLKVC: High voltage not available",radius=120},
	
		{x=410+275*0+60+60,y=480,tooltip="ОЧ: Отсутствие частоты АРС\nOCh: No ARS frequency",radius=120},
		{x=410+275*1+60+60,y=480,tooltip="0: Сигнал АРС остановки\n0: ARS stop signal",radius=120},
		{x=410+275*2+60+60,y=480,tooltip="40: Ограничение скорости 40 км/ч\nSpeed limit 40 kph",radius=120},
		{x=410+275*3+60+60,y=480,tooltip="60: Ограничение скорости 60 км/ч\nSpeed limit 60 kph",radius=120},
		{x=410+275*4+60+60,y=480,tooltip="75: Ограничение скорости 75 км/ч\nSpeed limit 75 kph",radius=120},
		{x=410+275*5+60+60,y=480,tooltip="80: Ограничение скорости 80 км/ч\nSpeed limit 80 kph",radius=120},

		{x=410+60,y=780+60,tooltip="ЛСД: Сигнализация дверей\nLSD: Door state light (doors are closed)",radius=120},
		{x=690+60,y=780+60,tooltip="ЛСД: Сигнализация дверей\nLSD: Door state light (doors are closed)",radius=120},
		
		{x=2540+60,y=780+60,tooltip="ЛСТ: Лампа сигнализации торможения\nLST: Brakes engaged",radius=120},
		{x=2540+60,y=330+60,tooltip="ЛВД: Лампа включения двигателей\nLVD: Engines engaged",radius=120},
		{x=2130+60,y=330+60,tooltip="ЛН: Лампа направления\nLN: Direction signal",radius=120},
		{x=2540+60,y=550+60,tooltip="ЛРС: Лампа равенства скоростей\nLRS: Speed equality light (next segment speed limit equal or greater to current)",radius=120},
	}
}

-- AV panel
ENT.ButtonMap["AV"] = {
	pos = Vector(387.0,-8.0,44.5),
	ang = Angle(0,90,90),
	width = 520,
	height = 550,
	scale = 0.0625,
	
	buttons = {
		{ID = "A61Toggle", x=16+51*0,  y=60+165*0, radius=30, tooltip="A61 Управление 6ым поездным проводом\nTrain wire 6 control"},
		{ID = "A55Toggle", x=16+51*1,  y=60+165*0, radius=30, tooltip="A55 Управление проводом 10АС\nTrain wire 10AS control"},
		{ID = "A54Toggle", x=16+51*2,  y=60+165*0, radius=30, tooltip="A54 Управление проводом 10АК\nTrain wire 10AK control"},
		{ID = "A56Toggle", x=16+51*3,  y=60+165*0, radius=30, tooltip="A56 Включение аккумуляторной батареи\nTurn on battery power to control circuits"},
		{ID = "A27Toggle", x=16+51*4,  y=60+165*0, radius=30, tooltip="A27 Turn on DIP and lighting"},
		{ID = "A21Toggle", x=16+51*5,  y=60+165*0, radius=30, tooltip="A21 Door control"},
		{ID = "A10Toggle", x=16+51*6,  y=60+165*0, radius=30, tooltip="A10 Motor-compressor control"},
		{ID = "A53Toggle", x=16+51*7,  y=60+165*0, radius=30, tooltip="A53 KVC power supply"},
		{ID = "A43Toggle", x=16+51*8,  y=60+165*0, radius=30, tooltip="A43 ARS 12V power supply"},
		{ID = "A45Toggle", x=16+51*9,  y=60+165*0, radius=30, tooltip="A45 ARS train wire 10AU"},
		{ID = "A42Toggle", x=16+51*10, y=60+165*0, radius=30, tooltip="A42 ARS 75V power supply"},
		{ID = "A41Toggle", x=16+51*11, y=60+165*0, radius=30, tooltip="A41 ARS braking"},		
		------------------------------------------------------------------------
		{ID = "VUToggle",  x=16+51*0,  y=60+165*1, radius=30, tooltip="VU  Train control"},
		{ID = "A64Toggle", x=16+51*1,  y=60+165*1, radius=30, tooltip="A64 Cabin lighting"},
		{ID = "A63Toggle", x=16+51*2,  y=60+165*1, radius=30, tooltip="A63 IGLA/BIS"},
		{ID = "A50Toggle", x=16+51*3,  y=60+165*1, radius=30, tooltip="A50 Turn on DIP and lighting"},
		{ID = "A51Toggle", x=16+51*4,  y=60+165*1, radius=30, tooltip="A51 Turn off DIP and lighting"},
		{ID = "A23Toggle", x=16+51*5,  y=60+165*1, radius=30, tooltip="A23 Emergency motor-compressor turn on"},
		{ID = "A14Toggle", x=16+51*6,  y=60+165*1, radius=30, tooltip="A14 Train wire 18"},
		{ID = "A75Toggle", x=16+51*7,  y=60+165*1, radius=30, tooltip="A75 Cabin heating"},
		{ID = "A1Toggle",  x=16+51*8,  y=60+165*1, radius=30, tooltip="A1  XOD-1"},
		{ID = "A2Toggle",  x=16+51*9,  y=60+165*1, radius=30, tooltip="A2  XOD-2"},
		{ID = "A3Toggle",  x=16+51*10, y=60+165*1, radius=30, tooltip="A3  XOD-3"},
		{ID = "A17Toggle", x=16+51*11, y=60+165*1, radius=30, tooltip="A17 Reset overload relay"},
		------------------------------------------------------------------------
		{ID = "A62Toggle", x=16+51*0,  y=60+165*2, radius=30, tooltip="A62 Radio communications"},
		{ID = "A29Toggle", x=16+51*1,  y=60+165*2, radius=30, tooltip="A29 Radio broadcasting"},
		{ID = "A5Toggle",  x=16+51*2,  y=60+165*2, radius=30, tooltip="A5  "},
		{ID = "A6Toggle",  x=16+51*3,  y=60+165*2, radius=30, tooltip="A6  T-1"},
		{ID = "A8Toggle",  x=16+51*4,  y=60+165*2, radius=30, tooltip="A8  Pneumatic valves #1, #2"},
		{ID = "A20Toggle", x=16+51*5,  y=60+165*2, radius=30, tooltip="A20 Drive/brake circuit control, train wire 20"},
		{ID = "A25Toggle", x=16+51*6,  y=60+165*2, radius=30, tooltip="A25 Manual electric braking"},
		{ID = "A22Toggle", x=16+51*7,  y=60+165*2, radius=30, tooltip="A22 Turn on KK"},
		{ID = "A30Toggle", x=16+51*8,  y=60+165*2, radius=30, tooltip="A30 Rheostat controller motor power"},
		{ID = "A39Toggle", x=16+51*9,  y=60+165*2, radius=30, tooltip="A39 Emergency control"},
		{ID = "A44Toggle", x=16+51*10, y=60+165*2, radius=30, tooltip="A44 Emergency train control"},
		{ID = "A80Toggle", x=16+51*11, y=60+165*2, radius=30, tooltip="A80 Power circuit mode switch motor power"},
		------------------------------------------------------------------------
		{ID = "A65Toggle", x=16+44*0,  y=60+165*3, radius=30, tooltip="A65 Interior lighting"},
		--{ID = "A00Toggle", x=16+51*1,  y=60+165*3, radius=30, tooltip="A00"},
		{ID = "A24Toggle", x=16+51*2,  y=60+165*3, radius=30, tooltip="A24 Battery charging"},
		{ID = "A32Toggle", x=16+51*3,  y=60+165*3, radius=30, tooltip="A32 Open right doors"},
		{ID = "A31Toggle", x=16+51*4,  y=60+165*3, radius=30, tooltip="A31 Open left doors"},
		{ID = "A16Toggle", x=16+51*5,  y=60+165*3, radius=30, tooltip="A16 Close doors"},
		{ID = "A13Toggle", x=16+51*6,  y=60+165*3, radius=30, tooltip="A13 Door alarm"},
		{ID = "A12Toggle", x=16+51*7,  y=60+165*3, radius=30, tooltip="A12 Emergency door close"},
		{ID = "A7Toggle",  x=16+51*8,  y=60+165*3, radius=30, tooltip="A7  Red lamp"},
		{ID = "A9Toggle",  x=16+51*9,  y=60+165*3, radius=30, tooltip="A9  Red lamp"},
		{ID = "A46Toggle", x=16+51*10, y=60+165*3, radius=30, tooltip="A46 White lamp"},
		{ID = "A47Toggle", x=16+51*11, y=60+165*3, radius=30, tooltip="A47 White lamp"},
	}
}

-- Battery panel
ENT.ButtonMap["Battery"] = {
	pos = Vector(398.0,-54.5,25.0),
	ang = Angle(0,90,90),
	width = 140,
	height = 260,
	scale = 0.0625,
	
	buttons = {
		{ID = "VBToggle", x=64, y=185, radius=70, tooltip="ВБ: Выключатель батареи\nVB: Battery on/off"},
	}
}

-- Help panel
ENT.ButtonMap["Help"] = {
	pos = Vector(422.0,-43.5,-4.5),
	ang = Angle(0,0,0),
	width = 20,
	height = 20,
	scale = 1,
	
	buttons = {
		{ID = "ShowHelp", x=10, y=10, radius=15, tooltip="Помощь в вождении поезда\nShow help on driving the train"},
	}
}

-- Pneumatic instrument panel
ENT.ButtonMap["PneumaticPanels"] = {
	pos = Vector(448.2,-9.0,8.0),
	ang = Angle(0,-90,56.5),
	width = 310,
	height = 120,
	scale = 0.0625,
	
	buttons = {
		{x=200,y=55,radius=55,tooltip="Давление в тормозных цилиндрах (ТЦ)\nBrake cylinder pressure"},
		{x=65,y=55,radius=55,tooltip="Давление в магистралях (красная: тормозной, чёрная: напорной)\nPressure in pneumatic lines (red: brake line, black: train line)"},
	}
}
ENT.ButtonMap["DriverValveDisconnect"] = {
	pos = Vector(410.0,-26.5,-38),
	ang = Angle(0,0,0),
	width = 200,
	height = 90,
	scale = 0.0625,
	
	buttons = {
		{ID = "DriverValveDisconnectToggle", x=0, y=0, w=200, h=90, tooltip="Клапан разобщения\nDriver valve disconnect valve"},
	}
}
ENT.ButtonMap["DURA"] = {
	pos = Vector(412.5,-56.5,-2.6),
	ang = Angle(0,0,0),
	width = 240,
	height = 80,
	scale = 0.0625,
	
	buttons = {
		{ID = "DURASelectMain", x=95, y=43, radius=20, tooltip="DURA Select Main"}, -- NEEDS TRANSLATING
		{ID = "DURASelectAlternate", x=60, y=43, radius=20, tooltip="DURA Select Alternate"}, -- NEEDS TRANSLATING
		{ID = "DURAToggleChannel", x=140, y=30, radius=20, tooltip="DURA Toggle Channel"}, -- NEEDS TRANSLATING
	}
}
ENT.ButtonMap["Reverser"] = {
	pos = Vector(436.0,-28.5,-7),
	ang = Angle(0,180,90),
	width = 180,
	height = 150,
	scale = 0.0625,
	
	buttons = {
		{ID = "KVReverserDown",x=10,y=0,w=160,h=70, tooltip=""},
		{ID = "KVReverserUp",x=10,y=80,w=160,h=70, tooltip=""},
	}
}
ENT.ButtonMap["Controller"] = {
	pos = Vector(440.0,25.5,-7),
	ang = Angle(0,-90,0),
	width = 180,
	height = 390,
	scale = 0.0625,
	
	buttons = {
		{ID = "KVControllerUp",x=10,y=0,w=160,h=190, tooltip=""},
		{ID = "KVControllerDown",x=10,y=200,w=160,h=190, tooltip=""},
	}
}
ENT.ButtonMap["Controller"] = {
	pos = Vector(440.0,25.5,-7),
	ang = Angle(0,-90,0),
	width = 180,
	height = 390,
	scale = 0.0625,
	
	buttons = {
		{ID = "KVControllerUp",x=10,y=0,w=160,h=190, tooltip=""},
		{ID = "KVControllerDown",x=10,y=200,w=160,h=190, tooltip=""},
	}
}
ENT.ButtonMap["DriversValve"] = {
	pos = Vector(429.0,-12.5,-7),
	ang = Angle(0,-90,0),
	width = 100,
	height = 200,
	scale = 0.0625,
	
	buttons = {
		{ID = "PneumaticBrakeDown",x=0,y=0,w=100,h=100, tooltip=""},
		{ID = "PneumaticBrakeUp",x=0,y=100,w=100,h=100, tooltip=""},
	}
}
ENT.ButtonMap["Meters"] = {
	pos = Vector(448.8,-34.0,24.0),
	ang = Angle(0,-125,90),
	width = 95,
	height = 150,
	scale = 0.0625,
	
	buttons = {
		{x=22, y=24, w=55, h=45, tooltip="Вольтметр высокого напряжения (кВ)\nHV voltmeter (kV)"},
		{x=22, y=85, w=58, h=45, tooltip="Амперметр (А)\nTotal ampermeter (A)"},
	}
}


--These values should be identical to those drawing the schedule
local col1w = 80 -- 1st Column width
local col2w = 32 -- The other column widths
local rowtall = 30 -- Row height, includes -only- the usable space and not any lines

local rowamount = 16 -- How many rows to show (total)
ENT.ButtonMap["Schedule"] = {
	pos = Vector(452.5,32.5,35),
	ang = Angle(0,-60,90),
	width = (col1w + 2 + (1 + col2w) * 3),
	height = (rowtall+1)*rowamount+1,
	scale = 0.0625/2,
	
	buttons = {
		{x=1, y=1, w=col1w, h=rowtall, tooltip="М №\nRoute number"},
		{x=1, y=rowtall*2+3, w=col1w, h=rowtall, tooltip="П №\nPath number"},
		
		{x=col1w+2, y=1, w=col2w*3+2, h=rowtall, tooltip="ВРЕМЯ ХОДА\nTotal schedule time"},
		{x=col1w+2, y=rowtall+2, w=col2w*3+2, h=rowtall, tooltip="ИНТ\nTrain interval"},
		
		{x=col1w+2, y=rowtall*2+3, w=col2w, h=rowtall, tooltip="ЧАС\nHour"},
		{x=col1w+col2w+3, y=rowtall*2+3, w=col2w, h=rowtall, tooltip="МИН\nMinute"},
		{x=col1w+col2w*2+4, y=rowtall*2+3, w=col2w, h=rowtall, tooltip="СЕК\nSecond"},
		{x=col1w+2, y=rowtall*3+4, w=col2w*3+2, h=(rowtall+1)*(rowamount-3)-1, tooltip="Arrival times"}, -- NEEDS TRANSLATING
		
		{x=1, y=rowtall*3+4, w=col1w, h=(rowtall+1)*(rowamount-3)-1, tooltip="Station name"}, -- NEEDS TRANSLATING
	}
}

-- Temporary panels (possibly temporary)
ENT.ButtonMap["FrontPneumatic"] = {
	pos = Vector(460.0,-45.0,-50.0),
	ang = Angle(0,90,90),
	width = 900,
	height = 100,
	scale = 0.1,
}
ENT.ButtonMap["RearPneumatic"] = {
	pos = Vector(-483.0,45.0,-50.0),
	ang = Angle(0,270,90),
	width = 900,
	height = 100,
	scale = 0.1,
}




--------------------------------------------------------------------------------
ENT.ClientPropsInitialized = false
ENT.ClientProps["brake"] = {
	model = "models/metrostroi/81-717/brake.mdl",
	pos = Vector(425.6,-24.8+1.5,-9.3),
	ang = Angle(0,180,0)
}
ENT.ClientProps["controller"] = {
	model = "models/metrostroi/81-717/controller.mdl",
	pos = Vector(430,17.0+1.5,-13.6),
	ang = Angle(0,180,0)
}
ENT.ClientProps["reverser"] = {
	model = "models/metrostroi/81-717/reverser.mdl",
	pos = Vector(433.8,-30.5+1.5,-12.8),
	ang = Angle(90,0,0)
}
ENT.ClientProps["brake_disconnect"] = {
	model = "models/metrostroi/81-717/uava.mdl",
	pos = Vector(419.6,-31.0+1.5,-38),
	ang = Angle(0,0,0)
}
--------------------------------------------------------------------------------
ENT.ClientProps["train_line"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(449.00,-16.05+1.5,3.40),
	ang = Angle(90+33,0,180+35.5)
}
ENT.ClientProps["brake_line"] = {
	model = "models/metrostroi/81-717/red_arrow.mdl",
	pos = Vector(448.88,-16.00+1.5,3.40),
	ang = Angle(90+33,0,180+35.5)
}
ENT.ClientProps["brake_cylinder"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(449.0,-24.28+1.5,3.40),
	ang = Angle(90+33,0,180+35.5)
}
--------------------------------------------------------------------------------
ENT.ClientProps["ampermeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(447.10,-38.10+1.5,16.00),
	ang = Angle(90,0,-45+180+80)
}
ENT.ClientProps["voltmeter"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(447.10,-38.10+1.5,19.80),
	ang = Angle(90,0,-45+180+80)
}
ENT.ClientProps["volt1"] = {
	model = "models/metrostroi/81-717/black_arrow.mdl",
	pos = Vector(448.30,15.10+1.5,3.10),
	ang = Angle(90+33,0,180-35.5)
}




--------------------------------------------------------------------------------
Metrostroi.ClientPropForButton("headlights",{
	panel = "Front",
	button = "VUSToggle",	
	model = "models/metrostroi/81-717/switch04.mdl",
})
ENT.ClientProps["dura"] = {
	model = "models/metrostroi/81-717/dura.mdl",
	pos = Vector(420.0,-58.3+1.5,-5.0),
	ang = Angle(0,0,90)
}
--------------------------------------------------------------------------------
Metrostroi.ClientPropForButton("BPSNon",{
	panel = "BPSNFront",
	button = "BPSNonToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("VozvratRP",{
	panel = "Main",
	button = "VozvratRPSet",
	model = "models/metrostroi/81-717/button03.mdl",
	z = 3,
})
Metrostroi.ClientPropForButton("VMK",{
	panel = "BPSNFront",
	button = "VMKToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("RezMK",{
	panel = "Front",
	button = "RezMKSet",
	model = "models/metrostroi/81-717/button04.mdl",
	z=4
})
Metrostroi.ClientPropForButton("VAH",{
	panel = "Front",
	button = "VAHToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("VAD",{
	panel = "Front",
	button = "VADToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("ALS",{
	panel = "Main",
	button = "ALSToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("ARS",{
	panel = "Main",
	button = "ARSToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("OtklAVU",{
	panel = "Main",
	button = "OtklAVUToggle",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("KRZD",{
	panel = "Main",
	button = "KRZDSet",	
	model = "models/metrostroi/81-717/button02.mdl",
	z = 3,
})
Metrostroi.ClientPropForButton("VUD1",{
	panel = "Main",
	button = "VUD1Toggle",
	model = "models/metrostroi/81-717/switch01.mdl",
})
Metrostroi.ClientPropForButton("DoorSelect",{
	panel = "Main",
	button = "DoorSelectToggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("KDL",{
	panel = "Main",
	button = "KDLSet",
	model = "models/metrostroi/81-717/button08.mdl",
})
Metrostroi.ClientPropForButton("KDP",{
	panel = "Front",
	button = "KDPSet",
	model = "models/metrostroi/81-717/button07.mdl",
})
Metrostroi.ClientPropForButton("KVT",{
	panel = "Main",
	button = "KVTSet",
	model = "models/metrostroi/81-717/button10.mdl",
})
Metrostroi.ClientPropForButton("KSN",{
	panel = "Main",
	button = "KSNSet",
	model = "models/metrostroi/81-717/button02.mdl"
})
Metrostroi.ClientPropForButton("KRP",{
	panel = "Front",
	button = "KRPSet",
	model = "models/metrostroi/81-717/button04.mdl",
	z=4
})
Metrostroi.ClientPropForButton("VDL",{
	panel = "Main",
	button = "VDLSet",
	model = "models/metrostroi/81-717/button08.mdl",
	z=2
})

Metrostroi.ClientPropForButton("SelectMain",{
	panel = "DURA",
	button = "DURASelectMain",
	model = "models/metrostroi/81-717/button07.mdl",
})
Metrostroi.ClientPropForButton("SelectAlternate",{
	panel = "DURA",
	button = "DURASelectAlternate",
	model = "models/metrostroi/81-717/button07.mdl",
})
Metrostroi.ClientPropForButton("SelectChannel",{
	panel = "DURA",
	button = "DURAToggleChannel",
	model = "models/metrostroi/81-717/switch04.mdl",
})
Metrostroi.ClientPropForButton("GreenRPLight",{
	panel = "Main",
	button = "GreenRPLight",
	model = "models/metrostroi/81-717/light02.mdl",
})
Metrostroi.ClientPropForButton("AVULight",{
	panel = "Main",
	button = "AVULight",
	model = "models/metrostroi/81-717/light01.mdl",
})
Metrostroi.ClientPropForButton("KVPLight",{
	panel = "Main",
	button = "KVPLight",
	model = "models/metrostroi/81-717/light03.mdl",
})
Metrostroi.ClientPropForButton("SPLight",{
	panel = "Main",
	button = "SPLight",
	model = "models/metrostroi/81-717/light04.mdl",
})
Metrostroi.ClientPropForButton("CabinHeatLight",{
	panel = "Front",
	button = "CabinHeatLight",
	model = "models/metrostroi/81-717/light04.mdl",
})
Metrostroi.ClientPropForButton("PneumoLight",{
	panel = "Front",
	button = "PneumoLight",
	model = "models/metrostroi/81-717/light04.mdl",
})

-- Placeholders
Metrostroi.ClientPropForButton("L_4",{
	panel = "Front",
	button = "L_4Toggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("PS2",{
	panel = "Main",
	button = "PS2",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("L_1",{
	panel = "Main",
	button = "L_1Toggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("L_2",{
	panel = "Main",
	button = "L_2Toggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("L_3",{
	panel = "Main",
	button = "L_3Toggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("PS6",{
	panel = "Main",
	button = "PS6",
	model = "models/metrostroi/81-717/button07.mdl"
})
Metrostroi.ClientPropForButton("DIPoff",{
	panel = "Main",
	button = "DIPoffSet",
	model = "models/metrostroi/81-717/button07.mdl"
})
Metrostroi.ClientPropForButton("PS8",{
	panel = "Main",
	button = "PS8",
	model = "models/metrostroi/81-717/button10.mdl"
})
Metrostroi.ClientPropForButton("L_5",{
	panel = "BPSNFront",
	button = "L_5Toggle",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("PS9",{
	panel = "BPSNFront",
	button = "PS9",
	model = "models/metrostroi/81-717/button07.mdl"
})
Metrostroi.ClientPropForButton("PS10",{
	panel = "BPSNFront",
	button = "PS10",
	model = "models/metrostroi/81-717/button07.mdl"
})
Metrostroi.ClientPropForButton("PS20",{
	panel = "Main",
	button = "PS20",
	model = "models/metrostroi/81-717/switch04.mdl"
})
Metrostroi.ClientPropForButton("PS21",{
	panel = "Main",
	button = "PS21",
	model = "models/metrostroi/81-717/switch04.mdl"
})


--------------------------------------------------------------------------------
ENT.ClientProps["gv"] = {
	model = "models/metrostroi/81-717/gv.mdl",
	pos = Vector(154,62.5+1.5,-65),
	ang = Angle(180,0,-90)
}
ENT.ClientProps["gv_wrench"] = {
	model = "models/metrostroi/81-717/reverser.mdl",
	pos = Vector(154,62.5+1.5,-65),
	ang = Angle(-50,0,0)
}
--------------------------------------------------------------------------------
for x=0,11 do
	for y=0,3 do
		ENT.ClientProps["a"..(x+12*y)] = {
			model = "models/metrostroi/81-717/circuit_breaker.mdl",
			pos = Vector(386.3,-7.5+x*3.26,40.4-y*10.2),
			ang = Angle(90,0,0)
		}
	end
end
Metrostroi.ClientPropForButton("battery",{
	panel = "Battery",
	button = "VBToggle",	
	model = "models/metrostroi/81-717/switch01.mdl",
	z = -10.7,
})

--------------------------------------------------------------------------------
ENT.ClientProps["book"] = {
	model = "models/props_lab/binderredlabel.mdl",
	pos = Vector(430.0,-53.0+1.5,-4.5),
	ang = Angle(0,50,90)
}




--------------------------------------------------------------------------------
-- Add doors
local function GetDoorPosition(i,k,j)
	if j == 0 
	then return Vector(351.0 - 34*k     - 231*i,-65*(1-2*k),-1.8)
	else return Vector(351.0 - 34*(1-k) - 231*i,-65*(1-2*k),-1.8)
	end
end
for i=0,3 do
	for k=0,1 do
		ENT.ClientProps["door"..i.."x"..k.."a"] = {
			model = "models/metrostroi/81/81-717_door3.mdl",
			pos = GetDoorPosition(i,k,0),
			ang = Angle(0,180*k,0)
		}
		ENT.ClientProps["door"..i.."x"..k.."b"] = {
			model = "models/metrostroi/81/81-717_door4.mdl",
			pos = GetDoorPosition(i,k,1),
			ang = Angle(0,180*k,0)
		}
	end
end
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81/81-717_door2.mdl",
	pos = Vector(-481.0,-0.5,-5.5),
	ang = Angle(0,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81/81-717_door1.mdl",
	pos = Vector(373.0,45.0,5.-5.5),
	ang = Angle(0,0,0)
})
table.insert(ENT.ClientProps,{
	model = "models/metrostroi/81/81-717_door5.mdl",
	pos = Vector(424.3,65.0,-2.8),
	ang = Angle(0,0,0)
})




--------------------------------------------------------------------------------
function ENT:Think()
	self.BaseClass.Think(self)

	-- Simulate pressure gauges getting stuck a little
	self:Animate("brake", 			self:GetPackedRatio(0)^0.5, 		0.00, 0.65,  256,24)
	self:Animate("controller",		1-self:GetPackedRatio(1),			0.30, 0.70,  384,24)
	self:Animate("reverser",		self:GetPackedRatio(2),				0.25, 0.75,  4,false)
	self:Animate("volt1", 			self:GetPackedRatio(10),			0.38, 0.64)
	self:ShowHide("reverser",		self:GetPackedBool(0))

	self:Animate("brake_line",		self:GetPackedRatio(4),				0.16, 0.84,  256,2,0.01)
	self:Animate("train_line",		self:GetPackedRatio(5),				0.16, 0.84,  256,2,0.01)
	self:Animate("brake_cylinder",	self:GetPackedRatio(6),	 			0.17, 0.86,  256,2,0.03)
	self:Animate("voltmeter",		self:GetPackedRatio(7),				0.35, 0.64)
	self:Animate("ampermeter",		self:GetPackedRatio(8),				0.37, 0.63)
	
	self:Animate("headlights",		self:GetPackedBool(1) and 1 or 0, 	0,1, 8, false)
	self:Animate("VozvratRP",		self:GetPackedBool(2) and 1 or 0, 	0,1, 16, false)
	self:Animate("DIPon",			self:GetPackedBool(3) and 1 or 0, 	0,1, 16, false)
	self:Animate("DIPoff",			self:GetPackedBool(4) and 1 or 0, 	0,1, 16, false)	
	self:Animate("brake_disconnect",self:GetPackedBool(6) and 1 or 0, 	0,0.7, 3, false)
	self:Animate("battery",			self:GetPackedBool(7) and 1 or 0, 	0,1, 16, false)
	self:Animate("RezMK",			self:GetPackedBool(8) and 1 or 0, 	0,1, 16, false)
	self:Animate("VMK",				self:GetPackedBool(9) and 1 or 0, 	0,1, 16, false)
	self:Animate("VAH",				self:GetPackedBool(10) and 1 or 0, 	0,1, 16, false)
	self:Animate("VAD",				self:GetPackedBool(11) and 1 or 0, 	0,1, 16, false)
	self:Animate("VUD1",			self:GetPackedBool(12) and 1 or 0, 	0,1, 16, false)
	--self:Animate("VUD2",			self:GetPackedBool(13) and 1 or 0, 	0,1, 16, false)
	self:Animate("VDL",				self:GetPackedBool(14) and 1 or 0, 	0,1, 16, false)
	self:Animate("KDL",				self:GetPackedBool(15) and 1 or 0, 	0,1, 16, false)
	self:Animate("KDP",				self:GetPackedBool(16) and 1 or 0, 	0,1, 16, false)
	self:Animate("KRZD",			self:GetPackedBool(17) and 1 or 0, 	0,1, 16, false)
	self:Animate("KSN",				self:GetPackedBool(18) and 1 or 0, 	0,1, 16, false)
	self:Animate("OtklAVU",			self:GetPackedBool(19) and 1 or 0, 	0,1, 16, false)
	self:Animate("SelectMain",		self:GetPackedBool(29) and 1 or 0, 	0,1, 16, false)
	self:Animate("SelectAlternate",	self:GetPackedBool(30) and 1 or 0, 	0,1, 16, false)
	self:Animate("SelectChannel",	self:GetPackedBool(31) and 1 or 0, 	0,1, 16, false)
	self:Animate("ARS",				self:GetPackedBool(56) and 1 or 0, 	0,1, 16, false)
	self:Animate("ALS",				self:GetPackedBool(57) and 1 or 0, 	0,1, 16, false)
	self:Animate("BPSNon",			self:GetPackedBool(59) and 1 or 0, 	0,1, 16, false)
	self:Animate("L_1",				self:GetPackedBool(60) and 1 or 0, 	0,1, 16, false)
	self:Animate("L_2",				self:GetPackedBool(61) and 1 or 0, 	0,1, 16, false)
	self:Animate("L_3",				self:GetPackedBool(62) and 1 or 0, 	0,1, 16, false)
	self:Animate("L_4",				self:GetPackedBool(63) and 1 or 0, 	0,1, 16, false)
	self:Animate("L_5",				self:GetPackedBool(53) and 1 or 0, 	0,1, 16, false)	
	
	-- Animate AV switches
	for i,v in ipairs(self.Panel.AVMap) do
		local value = self:GetPackedBool(64+(i-1)) and 1 or 0
		self:Animate("a"..(i-1),value,0,1,8,false)
	end	
	
	-- Main switch
	if self.LastValue ~= self:GetPackedBool(5) then
		self.ResetTime = CurTime()+2.0
		self.LastValue = self:GetPackedBool(5)
	end	
	self:Animate("gv_wrench",	1-(self:GetPackedBool(5) and 1 or 0), 	0,0.35, 32,  4,false)
	self:ShowHide("gv_wrench",	CurTime() < self.ResetTime)
	
	-- Animate doors
	for i=0,3 do
		for k=0,1 do
			local n_l = "door"..i.."x"..k.."a"
			local n_r = "door"..i.."x"..k.."b"
			local animation = self:Animate(n_l,self:GetPackedBool(21+i+4-k*4) and 1 or 0,0,1, 0.8 + (-0.2+0.4*math.random()),0)
			local offset_l = Vector(math.abs(31*animation),0,0)
			local offset_r = Vector(math.abs(32*animation),0,0)
			if self.ClientEnts[n_l] then
				self.ClientEnts[n_l]:SetPos(self:LocalToWorld(self.ClientProps[n_l].pos + (1.0 - 2.0*k)*offset_l))
			end
			if self.ClientEnts[n_r] then
				self.ClientEnts[n_r]:SetPos(self:LocalToWorld(self.ClientProps[n_r].pos - (1.0 - 2.0*k)*offset_r))
			end
		end
	end

	
	-- Brake-related sounds
	local brakeLinedPdT = self:GetPackedRatio(9)
	local dT = self.DeltaTime
	self.BrakeLineRamp1 = self.BrakeLineRamp1 or 0

	if (brakeLinedPdT > -0.001)
	then self.BrakeLineRamp1 = self.BrakeLineRamp1 + 2.0*(0-self.BrakeLineRamp1)*dT
	else self.BrakeLineRamp1 = self.BrakeLineRamp1 + 2.0*((-0.4*brakeLinedPdT)-self.BrakeLineRamp1)*dT
	end
	self:SetSoundState("release2",self.BrakeLineRamp1*0.75,1.0)

	self.BrakeLineRamp2 = self.BrakeLineRamp2 or 0
	if (brakeLinedPdT < 0.001)
	then self.BrakeLineRamp2 = self.BrakeLineRamp2 + 2.0*(0-self.BrakeLineRamp2)*dT
	else self.BrakeLineRamp2 = self.BrakeLineRamp2 + 2.0*(0.02*brakeLinedPdT-self.BrakeLineRamp2)*dT
	end
	self:SetSoundState("release3",self.BrakeLineRamp2,1.0)

	-- Compressor
	local state = self:GetPackedBool(20)
	self.PreviousCompressorState = self.PreviousCompressorState or false
	if self.PreviousCompressorState ~= state then
		self.PreviousCompressorState = state
		if not state then
			self:PlayOnce("compressor_end",nil,0.75)		
		end
	end
	self:SetSoundState("compressor",state and 1 or 0,1)
	
	-- ARS/ringer alert
	local state = self:GetPackedBool(39)
	self.PreviousAlertState = self.PreviousAlertState or false
	if self.PreviousAlertState ~= state then
		self.PreviousAlertState = state
		if state then
			self:SetSoundState("ring2",0.20,1)
		else
			self:SetSoundState("ring2",0,0)
			self:PlayOnce("ring2_end","cabin",0.45)		
		end
	end
	
	-- DIP sound
	self:SetSoundState("bpsn2",self:GetPackedBool(52) and 1 or 0,1.0)
	--self:SetSoundState("bpsn1",0,1.0)
end

function ENT:Draw()
	self.BaseClass.Draw(self)
	
	self:DrawOnPanel("ARS",function()
		surface.SetAlphaMultiplier(0.7)
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(108*10,13*10,24*10,24*10)
		surface.SetAlphaMultiplier(1.0)
	end)

	self:DrawOnPanel("ARS",function()
		if not self:GetPackedBool(32) then return end
	
		local speed = self:GetPackedRatio(3)*100.0
		local d1 = math.floor(speed) % 10
		local d2 = math.floor(speed / 10) % 10
		self:DrawDigit((110+0) *10,	16*10, d2, 0.85, 0.70)
		self:DrawDigit((110+11)*10,	16*10, d1, 0.85, 0.70)

		local b = self:Animate("light_rRP",self:GetPackedBool(35) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(255,120,50)
			surface.SetDrawColor(255,40,20)
			surface.DrawRect(178*10,78*10,17*10,9*10)
			surface.DrawRect(152*10,78*10,17*10,9*10)
			draw.DrawText("ЛСН","MetrostroiSubway_LargeText2",178*10+5,78*10-5,Color(0,0,0,245))
			draw.DrawText("РП","MetrostroiSubway_LargeText2",152*10+30,78*10-5,Color(0,0,0,245))
		end
		
		--b = self:Animate("light_gRP",self:GetPackedBool(36) and 1 or 0,0,1,15,false)
		--if b > 0.0 then
			--surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(50,255,50)
			--surface.DrawRect(152*10,78*10,17*10,9*10)
		--end
		
		b = self:Animate("light_KT",self:GetPackedBool(47) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(213*10,78*10,17*10,9*10)
			draw.DrawText("ЛКТ","MetrostroiSubway_LargeText2",213*10+5,78*10-5,Color(0,0,0,245))
		end			
		
		b = self:Animate("light_KVD",self:GetPackedBool(48) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(255,120,50)
			surface.SetDrawColor(255,40,20)
			surface.DrawRect(213*10,55*10,17*10,9*10)
			draw.DrawText("ЛКВД","MetrostroiSubway_LargeText3",213*10+5,55*10+5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_LhRK",self:GetPackedBool(33) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(255,160,20)
			surface.DrawRect(111*10,78*10,17*10,9*10)
			--draw.DrawText("ЛхРК","MetrostroiSubway_LargeText3",111*10+5,78*10+5,Color(0,0,0,245))
			draw.DrawText("РК","MetrostroiSubway_LargeText2",111*10+30,78*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_LRS",self:GetPackedBool(54) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(254*10,55*10,17*10,9*10)
			draw.DrawText("РС","MetrostroiSubway_LargeText2",254*10+35,55*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_LST",self:GetPackedBool(49) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(254*10,78*10,17*10,9*10)
			draw.DrawText("ЛСТ","MetrostroiSubway_LargeText2",254*10+5,78*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_LVD",self:GetPackedBool(50) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(254*10,33*10,17*10,9*10)
			draw.DrawText("ЛВД","MetrostroiSubway_LargeText2",254*10+5,33*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_LKVC",1-(self:GetPackedBool(34) and 1 or 0),0,1,5,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(255,120,50)
			surface.SetDrawColor(255,40,20)
			surface.DrawRect(254*10,10*10,17*10,9*10)
			draw.DrawText("ЛКВЦ","MetrostroiSubway_LargeText3",254*10+5,10*10+5,Color(0,0,0,245))
		end
		
		--[[b = self:Animate("light_NR1",self:GetPackedBool(34) and 1 or 0,0,1,15,false)
		b = 1
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(196*10,73*10,17*10,9*10)
		end
		
		b = self:Animate("light_PECH",self:GetPackedBool(37) and 1 or 0,0,1,15,false)
		b = 1
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(255,50,0)
			surface.DrawRect(260*10,73*10,17*10,9*10)
		end]]--
		
		--[[b = self:Animate("light_AVU",self:GetPackedBool(38) and 1 or 0,0,1,15,false)
		b = 1
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(295*10,73*10,17*10,9*10)
		end]]--
		
		b = self:Animate("light_SD",(self:GetPackedBool(40) and 1 or 0),0,1,5,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect(41*10,78*10,17*10,9*10)
			surface.DrawRect(69*10,78*10,17*10,9*10)
			draw.DrawText("ЛСД","MetrostroiSubway_LargeText2",41*10+5,78*10-5,Color(0,0,0,245))
			draw.DrawText("ЛСД","MetrostroiSubway_LargeText2",69*10+5,78*10-5,Color(0,0,0,245))
		end
	
		------------------------------------------------------------------------
		b = self:Animate("light_OCh",self:GetPackedBool(41) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(255,120,50)
			surface.SetDrawColor(255,40,20)
			surface.DrawRect((41+27.5*0)*10,48*10,17*10,9*10)
			draw.DrawText("ОЧ","MetrostroiSubway_LargeText2",(41+27.5*0)*10+30,48*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_0",self:GetPackedBool(42) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			--surface.SetDrawColor(255,120,50)
			surface.SetDrawColor(255,40,20)
			surface.DrawRect((41+27.5*1)*10,48*10,17*10,9*10)
			draw.DrawText("0","MetrostroiSubway_LargeText",(41+27.5*1)*10+60,48*10-5,Color(0,0,0,245))
		end
		
		b = self:Animate("light_40",self:GetPackedBool(43) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(255,160,20)
			surface.DrawRect((41+27.5*2)*10,48*10,17*10,9*10)
			draw.DrawText("40","MetrostroiSubway_LargeText",(41+27.5*2)*10+35,48*10-5,Color(0,0,0,245))
		end
			
		b = self:Animate("light_60",self:GetPackedBool(44) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect((41+27.5*3)*10,48*10,17*10,9*10)
			draw.DrawText("60","MetrostroiSubway_LargeText",(41+27.5*3)*10+35,48*10-5,Color(0,0,0,245))
		end
			
		b = self:Animate("light_70",self:GetPackedBool(45) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect((41+27.5*4)*10,48*10,17*10,9*10)
			draw.DrawText("70","MetrostroiSubway_LargeText",(41+27.5*4)*10+35,48*10-5,Color(0,0,0,245))
		end
			
		b = self:Animate("light_80",self:GetPackedBool(46) and 1 or 0,0,1,15,false)
		if b > 0.0 then
			surface.SetAlphaMultiplier(b)
			surface.SetDrawColor(50,255,50)
			surface.DrawRect((41+27.5*5)*10,48*10,17*10,9*10)
			draw.DrawText("80","MetrostroiSubway_LargeText",(41+27.5*5)*10+35,48*10-5,Color(0,0,0,245))
		end
		
		surface.SetAlphaMultiplier(1.0)
	end)
	
	self:DrawOnPanel("FrontPneumatic",function()
		draw.DrawText(self:GetNWBool("FI") and "Isolated" or "Open","Trebuchet24",150,30,Color(0,0,0,255))
	end)
	self:DrawOnPanel("RearPneumatic",function()
		draw.DrawText(self:GetNWBool("RI") and "Isolated" or "Open","Trebuchet24",150,30,Color(0,0,0,255))
	end)
	--self:DrawOnPanel("DURA",function()
		--surface.SetDrawColor(50,255,50)
		--surface.DrawRect(0,0,240,80)
	--end)
end

function ENT:OnButtonPressed(button)
	if button == "ShowHelp" then
		RunConsoleCommand("metrostroi_train_manual")
	end
end