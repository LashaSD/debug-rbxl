local examples_folder = script.Examples;
local example_names: {string} = {};
local examples = {};
local indices = {};
for i, v in examples_folder:GetChildren() do
    local example = require(v) :: () -> ();
    table.insert(examples, example);
    table.insert(example_names, v.Name);
    table.insert(indices, i);
end

table.sort(indices, function(a: number, b: number)
    return example_names[a] < example_names[b];
end);

local function Load_Nth_Example(n: number)
    examples[indices[n]]();
end

Load_Nth_Example(7);
