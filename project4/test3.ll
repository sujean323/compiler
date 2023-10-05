; === prologue ====
@str1= private unnamed_addr constant [4 x i8] c"%d\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 0, i32* %t1
store i32 100, i32* %t0
%t2=load i32, i32* %t1
%t3=load i32, i32* %t0
%t4 = add nsw i32 %t2, %t3
store i32 %t4, i32* %t0
%t5=load i32, i32* %t0
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str1, i64 0, i64 0),i32 %t5)
ret i32 0

; === epilogue ===
ret i32 0
}
