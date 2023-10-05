int main(){
    int i=1;
    while(i){
        printf("i=%d\n", i);
        i = i-1;   
    }
    
    for(i=0; i<5; i++){
        if(i>3)
            printf("i=4\n");
        else
            printf("hi\n");
    }
    if((i+1)>1 && (i%5)<1)
        return 0;
}