local Debug = require(script.Parent.Parent.Debug);

local function Example()
    local part_1 = Instance.new("Part", workspace);
    part_1.Anchored = true;
    part_1.Position = Vector3.new(10, 10, 10);

    local part_2 = Instance.new("Part", workspace);
    part_2.Anchored = true;
    part_2.Position = Vector3.new(-10, 10, -10);

    game:GetService("RunService").Heartbeat:Connect(function()
        local pos_1 = part_1.Position;
        local pos_2 = part_2.Position;

        Debug.Set_Next_Draw_Color(Color3.fromRGB(97, 255, 181));

        -- you can pass in vectors or Vector3s
        Debug.Draw_Line(pos_1, pos_2);
    end);
end

return Example;
