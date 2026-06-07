local Debug = require(script.Parent.Parent.Debug);

local function Example()
    local part_1 = Instance.new("Part", workspace);
    part_1.Anchored = true;
    part_1.Position = Vector3.new(10, 10, 10);

    local part_2 = Instance.new("Part", workspace);
    part_2.Anchored = true;
    part_2.Position = Vector3.new(-10, 10, -10);

    local line = Debug.Make_Line(part_1.Position, part_2.Position);
    Debug.Set_Line_Color(line, Color3.fromRGB(255, 0, 0));

    local function Update_Line()
        Debug.Set_Line(line, part_1.Position, part_2.Position);
    end

    part_1:GetPropertyChangedSignal("Position"):Connect(Update_Line);
    part_2:GetPropertyChangedSignal("Position"):Connect(Update_Line);
end

return Example;
