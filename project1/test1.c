#include<stdio.h>

void print(){
    printf("hello word\n");
}
int main(){
    int n=10;
    for(int i=0; i<n; i++){
        if(i<5){
            print();
            printf("i=%d\n", i);
        }
        else{
            continue;
            printf("i=%d\n", i);
        }
    }
    int k=512;
    printf("k = k >> 1 : %d\n", k = k >> 1);
    printf("k = k << 1 : %d\n", k = k << 1);

    return 0;
}
