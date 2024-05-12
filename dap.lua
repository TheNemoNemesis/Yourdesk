local dap = require("dap");

dap.adapters.lldb = {
    type = "executable",
    command = "/usr/bin/lldb-vscode",
    name = "lldb"
}

dap.configurations.zig = {
    {
        name = "Zig debug",
        type = "lldb",
        request = "launch",
        program = "zig-out/bin/YourDesk",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
