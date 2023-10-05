#include<stdio.h>
#include<string.h>

int func(char str1[], char str2[]){
    if(strcmp(str1, str2)==0)
        return 1;
    else return 0;
}
int main(){
    char str1[100] = "hello world";
    char str2[100];
    printf("input str2:\n");
    gets(str2);

    int k = func(str1, str2);
    printf("k=%d\n", k);

    return 0;
}
