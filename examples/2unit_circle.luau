local Debug = require(script.Debug_Library);

local center = vector.zero;
local function Heartbeat()
    local t = tick();

    -- play around with n
    local n = 10; -- 200;
    for i = 1, n do
        local offset = (i - 1) * (2 * math.pi / n);
        local x = math.cos(t + offset);
        local y = math.sin(t + offset);
        Debug.Draw_Line(center, center + vector.create(x, 0, y) * 10);
    end
end

local run_service = game:GetService("RunService");
run_service.Heartbeat:Connect(Heartbeat);
