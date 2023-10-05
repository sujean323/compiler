; === prologue ====
@str1= private unnamed_addr constant [13 x i8] c"Hello World\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 20, i32* %t0
call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @str1, i64 0, i64 0))

; === epilogue ===
ret i32 0
}
