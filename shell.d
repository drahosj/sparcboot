module shell;

import core.bios;
import core.string;

struct Command {
    const(char)[] name;
    const(char)[] help;
    int function(const(char)[]) func;
};

__gshared Command[4] commands;

extern (C) void shell_entry()
{
    write("Entering shell\n");

    commands[0].name = "help";
    commands[0].help = "Help command";
    commands[0].func = &help;

    while(true) {
        write("BOOTSHELL> ");

        char[128] buf;
        auto line = readline(buf[]);
        uint pos;

        auto cmd = strtok(buf, pos);
        write("Command entered: ");
        write(cmd);
        write("\n");
        if (cmd == "help") {
            write("Command was help.\n");
        }
        foreach(c; commands) {
            write("c.name: ");
            write(c.name);
            write("\n");
            if (c.name == cmd) {
                write("match found\n");
                //c.func(buf[pos..$]);
            }
        }
    }
}

int help(const(char)[] line)
{
    foreach(cmd; commands) {
        if (cmd.name) {
            write("\t");
            write(cmd.name);
            write("\t- ");
            write(cmd.help);
        }
    }
    return 0;
}
