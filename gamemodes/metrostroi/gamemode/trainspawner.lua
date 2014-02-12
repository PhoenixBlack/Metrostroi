local SPAWN_LIST = {}
local BOGEY_LENGTH = 162 --Not the full length, only distance from origin to forward tip

--1146.323242 -2998.176270 -2589.488770


SPAWN_LIST["DEPOT_CENTER"] = {
	Pos = Vector(-1337.93,-3759.17,-2613),
	Dir = Vector(-0.2,-0.98,0)
}

function SpawnTrain(spawnpoint,trainset)
	local sp = SPAWN_LIST[spawnpoint]
	if not sp then return end
	
	local Offset = BOGEY_LENGTH
	
	--TODO Function for spawning individual train and use that instead
	if type(trainset) == "string" then
		trainset = {trainset}
	end
	
	
	for k,v in pairs(trainset) do
		local train = ents.Create(v)
		if not IsValid(train) and train.BogeyDistance then return end
		local bd = train.BogeyDistance
		Offset = Offset + bd/2
		
		train:SetPos(sp.Pos+sp.Dir*Offset)
		train:SetAngles((sp.Dir*-1):Angle())
		train:Spawn()
		train:Activate()
		
		--train:GetPhysicsObject():EnableMotion(false)
		--TODO: Somehow make world owner
		
		Offset = Offset + bd/2 + BOGEY_LENGTH * 2
	end

end

function RemoveAllTrains()
	for k,v in pairs(ents.GetAll()) do
		if v.Base == "gmod_subway_base" then
			v:Remove()
		end
	end
end
