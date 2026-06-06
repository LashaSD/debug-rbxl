# debug-rbxl

the purpose of this library is to speed up the debugging process in roblox game development. it achieves this by allowing you to visualize your data, either displaying the values on the UI or drawing your vectors, points on the screen.

## Motivation behind the project
there are libraries, that support displaying data on the screen as UI or as gizmos with an immediate or retained API, but the problem i frequently faced while debugging with those libraries is the time it took to properly set it up, and the amount of state i needed to manage. i needed something, that doesn't distract me from the solution i'm debugging (or at least minimizes the distraction), which is why i decided to write this module.

## Setup
just download or copy the `src/Debug.luau` file into your project and you're ready to go. one of the main reasons i keep the module to a single file is so that it's easy to import into your project, without the need of package managers.

## Getting Started
there is no initializing required from your end, you can just `require()` the module and call any function you need.

you can view the `examples/` folder to get an understanding of the API.

## Unstable Functions
the functions in the API that are prefixed with _ are unstable, but they have good use cases when used properly.

they give the effect of using locally persistent memory, like in low level languages (static keyword in C).

if you know C, then this is a good example:
```c
{
    static int x = 10;
    ...
}
```

here x uses static memory instead of stack memory, so it's lifetime persists the local scope.

using my module:
```lua
local function Heartbeat()
    local x = Debug._Persist_Line();
    Debug.Set_Line(x, ...);

    local y = Debug._Persist_Line();
    Debug.Set_Line(y, ...);

    if some_condition then
        local line = Debug._Persist_Line();
        Debug.Set_Line(line, ...);
    end
end
```

here every single heartbeat the line that x references stays the same, same for y, and x != y. the use case for this is, that this allows us to not worry about state management.

here is a better use case for this:
```lua
local function Heartbeat()
    local avg = Debug._Average(some_value);
    print(avg);
end
```

instead of
```lua
local sum = 0;
local count = 0;
local function Heartbeat()
    sum += some_value;
    count += 1;
    local avg = sum / count;
    print(avg);
end
```

when tracking one average it seems like nothing, but imagine if you had to track 10 or more different averages, so this approach saves you from state management, because the module does it for you.

but why are these functions unstable?

because you can't call the same _ function on the same line.

this will give unexpected side effects:
```lua
local function Heartbeat()
    local avg_1, avg_2 = Debug._Average(v1), Debug_Average(v2);
end
```

to understand why, it's better that you look at the code.
