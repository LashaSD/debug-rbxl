local Debug = require(script.Parent.Parent.Debug);

local function Example(dt: number)
    local run_service = game:GetService("RunService");

    local x1_sum, x1_count = 0, 0;
    local x2_sum, x2_count = 0, 0;
    run_service.Heartbeat:Connect(function(dt: number)
        local alpha = (dt - 0.003) / (0.020 - 0.003);

        local color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), alpha);
        Debug.Set_Next_Text_Color(color);
        Debug.Text("Delta Time", dt);

        Debug.Push_Text_Color(Color3.fromRGB(128, 0, 128));
            Debug.Text("Alpha", alpha);
            Debug.Text("Random Value", math.random());
        Debug.Pop_Text_Color();

        local x_1, x_2 = math.random(), math.random();

        x1_sum += x_1;
        x1_count += 1;
        Debug.Text("Average_11", x1_sum / x1_count);

        Debug.Text("Average_12", Debug._Average(x_1));

        x2_sum += x_2;
        x2_count += 1;
        Debug.Text("Average_21", x2_sum / x2_count);

        Debug.Text("Average_22", Debug._Average(x_2));
    end);
end

return Example;
