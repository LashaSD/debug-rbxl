local Debug = require(script.Debug_Library);

-- fill in references to parts
local part_1 = ...;
local part_2 = ...;

-- this is using "immediate" API
game:GetService("RunService").Heartbeat:Connect(function()
    local pos_1 = part_1.Position;
    local pos_2 = part_2.Position;

    Debug.Set_Next_Draw_Color(Color3.fromRGB(97, 255, 181));

    -- you can pass in vectors or Vector3s
    Debug.Draw_Line(pos_1, pos_2);
end);

-- using retained API
local line = Debug.Make_Line(part_1.Position, part_2.Position);
Debug.Set_Line_Color(Color3.fromRGB(255, 0, 0));

local function Update_Line()
    Debug.Set_Line(line, part_1.Position, part_2.Position);
end

part_1:GetPropertyChangedSignal("Position"):Connect(Update_Line);
part_2:GetPropertyChangedSignal("Position"):Connect(Update_Line);
