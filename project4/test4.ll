; === prologue ====
@str6= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str5= private unnamed_addr constant [7 x i8] c"false\0A\00"
@str4= private unnamed_addr constant [9 x i8] c"true C2\0A\00"
@str3= private unnamed_addr constant [10 x i8] c"false C1\0A\00"
@str2= private unnamed_addr constant [9 x i8] c"true C1\0A\00"
@str1= private unnamed_addr constant [6 x i8] c"true\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 1, i32* %t1
store i32 2, i32* %t0
%t2=load i32, i32* %t1
%t3=load i32, i32* %t0
%t4 = icmp eq i32 %t2, %t3
br i1 %t4, label %L2, label %L3
br label  %L2
L2: ;
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str1, i64 0, i64 0))
%t5=load i32, i32* %t0
%t6=load i32, i32* %t0
%t7 = icmp ne i32 %t5, %t6
br i1 %t7, label %L5, label %L6
br label  %L5
L5: ;
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @str2, i64 0, i64 0))
br label  %L4
br label %L6
L6:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @str3, i64 0, i64 0))
br label %L4
L4:
br label  %L1
br label %L3
L3:
%t8=load i32, i32* %t1
%t9=load i32, i32* %t1
%t10 = icmp eq i32 %t8, %t9
br i1 %t10, label %L8, label %L9
br label  %L8
L8: ;
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @str4, i64 0, i64 0))
br label  %L7
br label %L9
L9:
br label %L7
L7:
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str5, i64 0, i64 0))
br label %L1
L1:
%t11=load i32, i32* %t1
%t12=load i32, i32* %t0
%t13 = add nsw i32 %t11, %t12
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str6, i64 0, i64 0),i32 %t13)
ret i32 0

; === epilogue ===
ret i32 0
}
