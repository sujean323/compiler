int main(){
    char str1[1024];
    char str2[1024];
    int len1 = 10;
    int len2;

    printf("Input string: \n");
    scanf("%s", str2);
    len2 = strlen(str2);

    printf("str1 = %s, str2 = %s\n", str1, str2);
    printf("len1 = %d, len2 = %d\n", len1, len2);

    if(len2)
        strcpy(str2, str1);
    if(len2 == len1)
        printf("success\n");
}