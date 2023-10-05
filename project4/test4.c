int main() {
    int a;
    int b;
    a = 1;
    b = 2;
    if (a == b) {
        
        printf("true\n");
        if (b != b) {
            printf("true C1\n");
        } else {
            printf("false C1\n");
        }
    } else {
        if (a == a) {
            printf("true C2\n");
        }
        printf("false\n");
    }
    printf("%d\n", a + b);
    return 0;
}