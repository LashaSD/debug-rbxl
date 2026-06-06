
-- Import
local Debug = require(script.Debug_Library);

local x1_sum, x1_count = 0, 0;
local x2_sum, x2_count = 0, 0;
local function ui_test(dt: number)
    local alpha = (dt - 0.003) / (0.020 - 0.003);

    Debug.Text("Delta Time", dt, Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), alpha));
    Debug.Text("Alpha", alpha);
    Debug.Text("Random Value", math.random());

    local x_1, x_2 = math.random(), math.random();

    x1_sum += x_1;
    x1_count += 1;
    Debug.Text("Average_11", x1_sum / x1_count);
    Debug.Text("Average_12", Debug._Average(x_1));

    x2_sum += x_2;
    x2_count += 1;
    Debug.Text("Average_21", x2_sum / x2_count);
    Debug.Text("Average_22", Debug._Average(x_2));
end

local MAX_DEPTH = 50;
local MAX_COUNT = 20000;
local lines = {};
for i = 1, MAX_COUNT do
    local index = Debug.Make_Line(Vector3.zero, vector.create(math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH)))
    table.insert(lines, index);
end

local og = Vector3.new(-5, 0, -5);
local function gizmo_test(dt: number)
    debug.profilebegin("gizmo_test()")

    local t = tick();
    local x = math.sin(t) * 5;
    local z = math.cos(t) * 5;
    local vec = Vector3.new(x + og.x, og.y, z + og.z);

    Debug.Set_Next_Draw_Color(Color3.fromRGB(255, 128, 0));
    Debug.Draw_Line(og, vec);

    Debug.Set_Next_Draw_Color(Color3.fromRGB(128, 128, 255));
    Debug.Set_Next_Point_Radius(.5);
    Debug.Draw_Point(vec);

    local rand = math.random();
    if rand > 0.9 then
        local line = Debug._Set_Line(og, vec);
        Debug.Set_Line_Color(line, Color3.new(rand, 1 - rand, rand));
    end

    for _, line_index in lines do
        Debug.Set_Line(line_index, vector.zero, vector.create(math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH), math.random(1, MAX_DEPTH)));
    end

    debug.profileend();
end

local function step(dt: number)
    ui_test(dt);
    gizmo_test(dt);
end

local run_service = game:GetService("RunService");
run_service.Heartbeat:Connect(step);
