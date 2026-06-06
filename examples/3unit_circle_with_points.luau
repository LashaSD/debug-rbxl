local Debug = require(script.Debug_Library);

local center = vector.zero;
local last_tick = tick();
local color_change_delay = 2;
local current_color = BrickColor.Random().Color;
local function Heartbeat()
    local t = tick();
    -- play around with n
    local n = 10; -- 200;
    for i = 1, n do
        local offset = (i - 1) * (2 * math.pi / n);
        local x = math.cos(t + offset);
        local y = math.sin(t + offset);

        if t - last_tick then
            current_color = BrickColor.Random().Color;
            last_tick = t;
        end

        local pos = center + vector.create(x, 0, y) * 10;
        local inner_offset = (2 * math.pi) / 3;
        Debug.Push_Point_Radius(0.25);
            Debug.Push_Draw_Color(current_color);
                Debug.Draw_Point(pos + vector.create(math.cos(t + inner_offset * 0), 0, math.sin(t + inner_offset * 0)));
                Debug.Draw_Point(pos + vector.create(math.cos(t + inner_offset * 1), 0, math.sin(t + inner_offset * 1)));
                Debug.Draw_Point(pos + vector.create(math.cos(t + inner_offset * 2), 0, math.sin(t + inner_offset * 2)));
            Debug.Pop_Draw_Color();
        Debug.Pop_Point_Radius();
    end
end

local run_service = game:GetService("RunService");
run_service.Heartbeat:Connect(Heartbeat);
