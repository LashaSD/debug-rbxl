local Debug = require(script.Parent.Parent.Debug);

local function Example(dt: number)
    local run_service = game:GetService("RunService");

    local MAX_DEPTH = 50;
    local n = 10000;
    local lines = {};
    for i = 1, n do
        table.insert(lines, Debug.Make_Line());
    end

    local free_rate = 1000; -- how many lines freed per second
    local free_period = 1 / free_rate; -- how many seconds to free 1 line

    local last_time_freed = tick();
    run_service.Heartbeat:Connect(function(dt)
        local t = tick();

        local free_count = math.min(#lines, (t - last_time_freed) / free_period);
        while free_count > 0 do
            last_time_freed = t;
            local line = table.remove(lines) :: number;
            Debug.Free_Line(line);
            free_count -= 1;
        end

        for _, line in lines do
            Debug.Set_Line(line, Vector3.zero, vector.create(math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH)))
        end

        Debug.Text("line_count = ", #lines);
    end);
end

return Example;
