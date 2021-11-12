module core.string;

const(char)[] strtok(const(char)[] str, ref uint pos, 
        const(char)[] delim = " \n\t")
{
    int oldpos = pos;

    if (pos >= str.length) {
        return [];
    }
    for (int i = pos; i < str.length; i++) {
        foreach (d; delim) {
            if (str[i] == d) {
                pos = i + 1;
                return str[oldpos..i];
            }
        }
    }

    pos = str.length;
    return str[oldpos..$];
}

unittest
{
    const(char)[] str = "this is a test string";
    uint pos;

    const(char)[] word;

    word = strtok(str, pos);
    assert(word == "this");

    word = strtok(str, pos);
    assert(word == "is");

    word == strtok(str, pos);
    assert(word == "a");

    word == strtok(str, pos);
    assert(word == "test");

    word == strtok(str, pos);
    assert(word == "string");

    word == strtok(str, pos);
    assert(!word);
}
