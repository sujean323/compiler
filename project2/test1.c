int main(){
    long a = 10000;
    short b = 5;
    int x = 0;
    int arr[50];

    switch(a){
        case 0:
            b++;
            break;
        case 1:
            b--;
            break;
        default:
            break;
    }
    while(a>9999){
        a = a-b;
    }
    for(a=0; a<10; a++)
        strcpy(arr, "9487");
    if(x)
        printf("%d\n", x^x);
}
