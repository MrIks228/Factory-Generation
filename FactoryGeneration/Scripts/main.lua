print("Script started")

local FactoryLevels = {
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory1",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory2",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory3",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory4",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory5",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory6",
    "/Game/Blueprints/WorldGeneration/WorldPresets/Developers/MIkalai/L_NormalFactory7"
}

local function MakeNames()
    local t = {}
    for i, v in ipairs(FactoryLevels) do
        t[i] = FName(v)
    end
    return t
end

local function LiftPlayer()
    local player = nil

    local pawns = FindAllOf("Pawn")
    if pawns then
        for _, p in ipairs(pawns) do
            if p:IsValid() then
                player = p
                break
            end
        end
    end

    if not player then
        print("[FG] player not found")
        return
    end

    local loc = player:K2_GetActorLocation()

    loc.Z = loc.Z + 1000 

    local hit = {}

    player:K2_SetActorLocation(loc, false, hit, false)

    print("[FG] player moved")
end

local function OverrideAll()

    local gens = FindAllOf("BP_WorldGeneration_Base_C")
    if not gens then return end

    print("[FG] generators: " .. #gens)

    local seed = math.random(1,999999)

    for _, g in ipairs(gens) do
        if g:IsValid() then

            print("[FG] override: " .. g:GetFullName())

            g.LevelNames = MakeNames()

            if g.UnloadLevels then
                g:UnloadLevels()
            end

            ExecuteWithDelay(500, function()
                g:RunGenerationFromSeed(seed, 0)
                g:GenerateNewRandomLevels()
                g:BeginCheckIfAllLevelsAreLoad()
            end)
        end
    end

    print("[FG] done")
end

LoopAsync(2000, function()
    local gens = FindAllOf("BP_WorldGeneration_Base_C")

    if gens and #gens >= 3 then
        ExecuteWithDelay(3000, OverrideAll)
        return true
    end

    return false
end)

RegisterKeyBind(Key.F8, function()
    local ok, err = pcall(LiftPlayer)
    if not ok then
        print("[ERROR] " .. tostring(err))
    end
end)
