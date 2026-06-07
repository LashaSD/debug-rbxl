local Debug = require(script.Parent.Parent.Debug);

local function Example(dt: number)
    local run_service = game:GetService("RunService");

    local center = vector.create(10, 0, 10);
    run_service.Heartbeat:Connect(function(dt)
        local t = tick();
        local x = math.sin(t) * 5;
        local z = math.cos(t) * 5;
        local target = center + vector.create(x, 0, z);

        Debug.Set_Next_Draw_Color(Color3.fromRGB(255, 128, 0));
        Debug.Draw_Line(center, target);

        Debug.Set_Next_Draw_Color(Color3.fromRGB(128, 128, 255));
        Debug.Set_Next_Point_Radius(.25);
        Debug.Draw_Point(target);

        local rand = math.random();
        if rand > 0.9 then
            -- if we do .Draw_Line() here, in the frames, where rand <= 0.9 the
            -- line will not render and it will disappear, but what if we want to
            -- keep rendering it, but not update it's position.
            -- here we could have tracked the state ourselves and kept redrawing it
            -- but we can instead use _Set_Line() for convenience.
            local line = Debug._Set_Line(center, target);
            Debug.Set_Line_Color(line, Color3.new(rand, 1 - rand, rand));
        end
    end);
end

return Example;
