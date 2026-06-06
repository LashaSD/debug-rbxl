--!native

-- Types
type Vec3 = Vector3 | vector;

-- Util Functions
local function Pack_Color(color: Color3)
    local r = math.round(color.R * 255);
    local g = math.round(color.G * 255);
    local b = math.round(color.B * 255);
    return bit32.bor(
        r,
        bit32.lshift(g, 8),
        bit32.lshift(b, 16)
    );
end

local function Unpack_Color(x: number)
    local mask8 = 2^8 - 1;
    local mask_r = mask8;
    local mask_g = bit32.lshift(mask8, 8);
    local mask_b = bit32.lshift(mask8, 16);

    return Color3.fromRGB(
        bit32.band(x, mask_r),
        bit32.rshift(bit32.band(x, mask_g), 8),
        bit32.rshift(bit32.band(x, mask_b), 16)
    );
end

--[=[
@param depth: how many calls away this function's caller is from the target call.
@return the target function call's source file path concatenated with the line number.
]=]
-- this function must be global, because it shouldnt be inlined
function Unstable_Persist_Key<T>(depth: number?): string
    local source: string, line: string = debug.info(depth and depth + 2 or 3, "sl");
    return source .. line;
end

local Debug = {};

--/ UI

--/ UI Texts
do
    type Text_Row = {
        text_1: TextLabel,
        text_2: TextLabel,
    } & Instance;

    local TEXT_SIZE = 20;
    local NUMBER_ROUNDING = 1e6;

    local DEFAULT_TEXT_COLOR = Color3.fromRGB(255, 255, 255);
    local DEFAULT_VALUE_COLOR = Color3.fromRGB(255, 255, 255);
    local DEFAULT_BACKGROUND_COLOR = Color3.fromRGB(0, 0, 0);

    local text_rendering_is_on = false;
    local render_frame: Frame? = nil;

    local text_rows: {Text_Row} = {};
    local text_queue: {string} = {};
    local value_queue: {string} = {};
    local color_queue: {Color3} = {};
    local old_queue_size = 0;

    local text_color_stack: {Color3} = {};
    local next_text_color: Color3? = nil;

    local function Make_Text_Row()
        local frame = Instance.new("Frame");
        frame.BorderSizePixel = 0;
        frame.BackgroundTransparency = .2;
        frame.BackgroundColor3 = DEFAULT_BACKGROUND_COLOR;

        local layout = Instance.new("UIListLayout");
        layout.FillDirection = Enum.FillDirection.Horizontal;
        layout.Parent = frame;

        local text_1 = Instance.new("TextLabel");
        text_1.Parent = frame;
        text_1.Size = UDim2.fromScale(0.5, 1);
        text_1.TextWrapped = true;
        text_1.BackgroundTransparency = 1;
        text_1.TextSize = TEXT_SIZE;
        text_1.TextColor3 = DEFAULT_TEXT_COLOR;
        text_1.Font = Enum.Font.RobotoCondensed;
        text_1.Name = "text_1";

        local text_2 = Instance.new("TextLabel");
        text_2.Parent = frame;
        text_2.Size = UDim2.fromScale(0, 1);
        text_2.TextWrapped = true;
        text_2.BackgroundTransparency = 1;
        text_2.TextSize = TEXT_SIZE;
        text_2.TextColor3 = DEFAULT_VALUE_COLOR;
        text_2.Font = Enum.Font.RobotoCondensed;
        text_2.Name = "text_2";

        local flex = Instance.new("UIFlexItem");
        flex.FlexMode = Enum.UIFlexMode.Fill;
        flex.Parent = text_2;

        return frame :: Text_Row;
    end

    local function Render_Texts()
        debug.profilebegin("Render_Texts()");

        local old_len = old_queue_size;
        local new_len = #text_queue;

        if new_len < old_len then
            -- render queue shrunk
            for i = new_len + 1, old_len do
                text_rows[i].Parent = nil;
            end
        elseif new_len > old_len then
            -- render queue grew
            local pool_len = #text_rows;
            for i = old_len + 1, new_len do
                if pool_len < i then
                    assert(i - pool_len == 1);
                    table.insert(text_rows :: any, Make_Text_Row());
                    pool_len += 1;
                end

                text_rows[i].Parent = render_frame;
            end
        end

        local current_size = 25;
        -- TODO(!!): fix the sizing situation of the text rows
        for i = 1, #text_queue do
            local t1 = text_queue[i];
            local t2 = value_queue[i];
            local color = color_queue[i];

            local text_row = text_rows[i];

            local x = 25;
            local udim = UDim2.fromOffset(x, current_size);
            if text_row.Position ~= udim then
                text_row.Position = udim;
            end

            text_row.Size = UDim2.fromOffset(t1:len() * TEXT_SIZE + 100, TEXT_SIZE + 10)
            text_row.text_1.Text = t1;
            text_row.text_2.Text = t2;
            text_row.text_2.TextColor3 = color;

            current_size += TEXT_SIZE + 10;
        end

        old_queue_size = #text_queue;
        table.clear(text_queue);
        table.clear(value_queue);
        table.clear(color_queue);

        debug.profileend();
    end

    local function Init_Text_Rendering()
        local gui = Instance.new("ScreenGui");

        local run_service = game:GetService("RunService");
        if run_service:IsClient() then
            local players = game:GetService("Players");
            local gui_folder = players.LocalPlayer.PlayerGui;
            gui.Parent = gui_folder;
        end

        render_frame = Instance.new("Frame", gui);
        render_frame.Size = UDim2.fromScale(1, 1);
        render_frame.BackgroundTransparency = 1;

        run_service.Heartbeat:Connect(Render_Texts);
    end

    local function Init_Text_Rendering_If_Not_Initialized()
        if not text_rendering_is_on then
            Init_Text_Rendering();
            text_rendering_is_on = true;
        end
    end

    function Debug.Text(text: string, value: unknown)
        Init_Text_Rendering_If_Not_Initialized();

        if value ~= nil and type(value) == "number" then
            value = (math.round(value * NUMBER_ROUNDING) / NUMBER_ROUNDING);
        end

        local color = next_text_color or table.remove(text_color_stack) or DEFAULT_VALUE_COLOR;
        next_text_color = nil;

        table.insert(text_queue, text);
        table.insert(value_queue, tostring(value));
        table.insert(color_queue, color);
    end

    function Debug.Push_Text_Color(color: Color3)
        table.insert(text_color_stack, color);
    end

    function Debug.Pop_Text_Color()
        assert(#text_color_stack > 0);
        table.remove(text_color_stack);
    end

    function Debug.Set_Next_Text_Color(color: Color3)
        next_text_color = color;
    end
end

--/ Gizmos
local draw_color_stack: {Color3} = {};
local next_draw_color: Color3? = nil;

function Debug.Push_Draw_Color(color: Color3)
    table.insert(draw_color_stack, color);
end

function Debug.Pop_Draw_Color()
    assert(#draw_color_stack > 0);
    table.remove(draw_color_stack);
end

function Debug.Set_Next_Draw_Color(color: Color3)
    next_draw_color = color;
end

--/ Gizmo Lines
do
    local LINE_DEFAULT_COLOR = Color3.fromRGB(13, 105, 172);

    local line_rendering_is_on = false;

    local wireframe = Instance.new("WireframeHandleAdornment");

    local re_first: {vector} = {};
    local re_second: {vector} = {};
    local re_color: {Color3} = {};
    local re_is_free: {[number]: boolean?} = {};
    local re_free_list: {number} = {};

    local color_batched_render_queue: {[number]: {vector}} = {};

    local function Render_Lines(dt: number)
        debug.profilebegin("Render_Lines()")

        for index, is_free in re_is_free do
            if is_free then continue; end

            local origin, target = re_first[index], re_second[index];
            local color = re_color[index];
            local packed_color = Pack_Color(color);

            if color_batched_render_queue[packed_color] == nil then
                color_batched_render_queue[packed_color] = {};
            end
            local queue = color_batched_render_queue[packed_color];

            table.insert(queue, origin);
            table.insert(queue, target);
        end

        wireframe:Clear();
        wireframe.Color3 = LINE_DEFAULT_COLOR;

        for packed_color, queue in color_batched_render_queue do
            assert(#queue % 2 == 0);
            wireframe.Color3 = Unpack_Color(packed_color);
            wireframe:AddLines(queue);
            table.clear(queue);
        end

        debug.profileend();
    end

    local function Init_Line_Rendering()
        wireframe.Adornee = workspace;
        wireframe.Parent = workspace:WaitForChild("Terrain");

        local run_service = game:GetService("RunService");
        run_service.Heartbeat:Connect(Render_Lines);
    end

    local function Init_Line_Rendering_If_Not_Initialized()
        if not line_rendering_is_on then
            Init_Line_Rendering();
            line_rendering_is_on = true;
        end
    end

    function Debug.Draw_Line(origin: Vec3, target: Vec3)
        origin = origin :: vector;
        target = target :: vector;

        Init_Line_Rendering_If_Not_Initialized();

        local color = draw_color_stack[#draw_color_stack] or LINE_DEFAULT_COLOR;
        if next_draw_color then
            color = next_draw_color;
            next_draw_color = nil;
        end
        local packed_color = Pack_Color(color);

        if color_batched_render_queue[packed_color] == nil then
            color_batched_render_queue[packed_color] = {};
        end

        local queue = color_batched_render_queue[packed_color];
        assert(#queue % 2 == 0);
        table.insert(queue, origin);
        table.insert(queue, target);
    end

    function Debug.Make_Line(origin: Vec3?, v: Vec3?)
        origin = (origin or vector.zero) :: vector;
        v = (v or vector.zero) :: vector;

        Init_Line_Rendering_If_Not_Initialized();

        local index = table.remove(re_free_list) or #re_first + 1;
        re_first[index] = origin;
        re_second[index] = v;
        re_color[index] = LINE_DEFAULT_COLOR;
        re_is_free[index] = false;

        return index;
    end

    function Debug.Set_Line(index: number, origin: Vec3, target: Vec3)
        origin = origin :: vector;
        target = target :: vector;

        assert(not re_is_free[index]);
        re_first[index] = origin;
        re_second[index] = target;
    end

    function Debug.Set_Line_Color(index: number, color: Color3)
        assert(not re_is_free[index]);
        re_color[index] = color;
    end

    function Debug.Free_Line(index: number)
        table.insert(re_free_list, index);
        re_is_free[index] = true;
    end

    local line_data: {[string]: number} = {};
    function Debug._Persist_Line()
        local key = Unstable_Persist_Key(1);
        if line_data[key] == nil then
            line_data[key] = Debug.Make_Line();
        end
        return line_data[key];
    end

    function Debug._Set_Line(origin: Vec3, target: Vec3)
        local key = Unstable_Persist_Key(1);
        if line_data[key] == nil then
            line_data[key] = Debug.Make_Line(origin, target);
            return line_data[key];
        end

        local index = line_data[key];
        Debug.Set_Line(index, origin, target);
        return index;
    end
end

--/ Gizmo Points
do
    type Point_Instance = SphereHandleAdornment;

    local INITIAL_POINT_POOL_SIZE = 50;
    local POINT_DEFAULT_COLOR = Color3.fromRGB(13, 105, 172);
    local POINT_DEFAULT_RADIUS = 1;

    local points: {Point_Instance} = {};

    local point_folder: Instance = nil :: any;

    local point_pos_queue: {vector} = {};
    local point_color_queue: {Color3} = {};
    local point_radius_queue: {number} = {};
    local old_queue_size = 0;

    local point_rendering_is_on = false;

    local radius_stack: {number} = {};
    local next_radius: number? = nil;

    local function Make_Point(): Point_Instance
        local point = Instance.new("SphereHandleAdornment");
        point.Parent = workspace:WaitForChild("Terrain");
        point.Adornee = workspace;
        return point;
    end
    Debug.Make_Point = Make_Point;

    local function Render_Points()
        debug.profilebegin("Render_Points()");

        local old_len = old_queue_size;
        local new_len = #point_pos_queue;

        if new_len < old_len then
            for i = new_len + 1, old_len do
                points[i].Adornee = nil :: any;
            end
        elseif new_len > old_len then
            local pool_size = #points;
            for i = old_len + 1, new_len do
                if pool_size < i then
                    assert(i - pool_size == 1);
                    table.insert(points, Make_Point());
                    pool_size += 1;
                end

                points[i].Adornee = workspace;
            end
        end

        for i = 1, new_len do
            points[i].CFrame = CFrame.new(point_pos_queue[i] :: any);
            points[i].Color3 = point_color_queue[i];
            points[i].Radius = point_radius_queue[i];
        end

        old_queue_size = new_len;
        table.clear(point_pos_queue);
        table.clear(point_color_queue);
        table.clear(point_radius_queue);

        debug.profileend();
    end

    local function Init_Point_Rendering()
        point_folder = workspace:WaitForChild("Terrain");

        for i = 1, INITIAL_POINT_POOL_SIZE do
            local p = Instance.new("SphereHandleAdornment");
            p.Parent = point_folder;
            table.insert(points, p);
        end

        local run_service = game:GetService("RunService");
        run_service.Heartbeat:Connect(Render_Points);
    end

    local function Init_Point_Rendering_If_Not_Initialized()
        if not point_rendering_is_on then
            Init_Point_Rendering();
            point_rendering_is_on = true;
        end
    end

    function Debug.Draw_Point(pos: Vec3)
        pos = pos :: vector;
        Init_Point_Rendering_If_Not_Initialized();
        assert(#point_pos_queue == #point_color_queue);
        assert(#point_pos_queue == #point_radius_queue);

        local color = draw_color_stack[#draw_color_stack] or POINT_DEFAULT_COLOR;
        if next_draw_color then
            color = next_draw_color;
            next_draw_color = nil;
        end

        local radius = radius_stack[#radius_stack] or POINT_DEFAULT_RADIUS;
        if next_radius then
            radius = next_radius;
            next_radius = nil;
        end

        table.insert(point_pos_queue, pos);
        table.insert(point_radius_queue, radius);
        table.insert(point_color_queue, color);
    end

    function Debug.Push_Point_Radius(radius: number)
        table.insert(radius_stack, radius);
    end

    function Debug.Pop_Point_Radius()
        assert(#radius_stack > 0);
        table.remove(radius_stack);
    end

    function Debug.Set_Next_Point_Radius(radius: number)
        next_radius = radius;
    end
end

--/ Misc
do
    local sum_data: {[string]: number} = {};
    local count_data: {[string]: number} = {};
    function Debug._Average(value: number)
        local key = Unstable_Persist_Key(1);
        if sum_data[key] == nil then
            assert(count_data[key] == nil);
            sum_data[key] = value;
            count_data[key] = 1;
        else
            assert(count_data[key] ~= nil);
            sum_data[key] += value;
            count_data[key] += 1;
        end

        return sum_data[key] / count_data[key];
    end
end

do
    local max_data: {[string]: number} = {};
    function Debug._Max(value: number)
        local key = Unstable_Persist_Key(1);
        if max_data[key] == nil then
            max_data[key] = value;
        else
            max_data[key] = math.max(max_data[key], value);
        end

        return max_data[key];
    end
end

do
    local min_data: {[string]: number} = {};
    function Debug._Min(value: number)
        local key = Unstable_Persist_Key(1);
        if min_data[key] == nil then
            min_data[key] = value;
        else
            min_data[key] = math.min(min_data[key], value);
        end

        return min_data[key];
    end
end

return table.freeze(Debug);
