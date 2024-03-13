int printf(const char*, ...);

int main()
{
    char a = 'A';
    char b = 'B';
    char c = 'C';
    char d = 'D';
    char e = 'E';
    char f = 'F';
    char g = 'G';
    printf("abcdef %% %c%c%c%c%c%c%c%c%c%c abcd\n", a, b, c, d, e, f, g, c, c, c);

    char* str = "Timur";
    printf("string = %s dada\n", str);

    int x = 7952812;
    int y = 15;
    long long z = -1120;
    printf("x = %d, y = %d\n", x, y);
    printf("z = %d\n", z);

    x = 7;
    y = 16;
    int t = -1;
    printf("x = %b, y = %b\n", x, y);
    printf("z = %b\n", t);

    x = 56;
    y = 17;
    t = -3;
    printf("x = %o, y = %o\n", x, y);
    printf("z = %o\n", t);

    x = 128;
    y = 3457; // D81
    t = -1;
    printf("x = %x, y = %x\n", x, y);
    printf("z = %x\n", t);

    return 0;
}